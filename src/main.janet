(import spork/getline)
(import spork/misc)
(import salesforce)

(var- url
      (->> (get (os/environ) "SF_URL")
           (string/replace "https://" "")
           (string/split ".")
           (first)))

(defn- cache/name [key]
  (let [prefix (string/format "./src/data/%s." url)
        postfix ".cache"]
    (string prefix key postfix)))

(defn- cache/age
  "Get key age in hours"
  [key]
  (let [now (os/time)
        last-modified (or (os/stat (cache/name key) :modified) 0)
        hour (* 60 60)]
    (/ (- now last-modified) hour)))

(defn- cache/store
  "Store a value under key"
  [key value]
  (let [out (dyn *out*)
        fmt (dyn :pretty-format)
        filename (cache/name key)
        file (file/open filename :w)]
    (setdyn *out* file)
    (setdyn :pretty-format "%.40n")
    (pp value)
    (file/close file)
    (setdyn *out* out)
    (setdyn :pretty-format fmt)))

(defn- cache/retrieve
  "Retrieve value by key"
  [key]
  (let [filename (cache/name key)]
    (when (os/stat filename)
      (parse (slurp filename)))))

(defn- describe
  "Retrieve metadata for an object"
  [object-name]
  (let [caching-duration-hours 24
        age (cache/age object-name)
        data (cache/retrieve object-name)]
    (if (and (< age caching-duration-hours) data)
      data
      (do
        (cache/store object-name (salesforce/describe object-name))
        (describe object-name)))))

(var object-name nil)
(var metadata nil)
(var search-data @{})

(defn normalize
  [str]
  (string/replace-all "_" "" (string/ascii-lower str)))

(defn setup-search-data []
  (set search-data
       (reduce
         (fn [acc el] (put acc (normalize (el "name")) el))
         @{} (get metadata "fields"))))

(def properties-we-care-about
  [
   # "calculatedFormula"
   # "precision"
   # "scale"
   # "calculated"
   # "extraTypeInfo"
   # "nillable"
   # "digits"
   # "createable"
   # "length"
   # "referenceTo"
   # "autoNumber"
   # "nameField"
   "picklistValues"
   "defaultValue"
   "type"
   "inlineHelpText"
   "name"
   "label"
  ])

(defn format-picklist-values
  [vals]
  (string/join
   (map |($ "label") (filter |($ "active") vals))
   ", "))

(defn details
  [field-name]
  (let [field (search-data (normalize field-name))
        metadata (misc/select-keys field properties-we-care-about)]
    (put metadata "picklistValues"
         (format-picklist-values (metadata "picklistValues")))
    (misc/print-table [metadata])))

(defn search
  [field-name]
  (let [needle (normalize field-name)
        haystack (keys search-data)
        matching-keys (if (empty? needle)
                        haystack
                        (filter |(string/find needle $) haystack))]
    (map |(print ((search-data $) "name")) matching-keys)))

(defn prompt []
  (let [input (string/trim (getline ""))]
    (if (string/has-prefix? ">" input)
      (details (string/trim (string/slice input 1)))
      (search input))))

(defn greeting []
  (print
   `Begin typing the field name, and then hit enter. Possible
   matches will be returned. To inspect one of the matches type >
   followed by the field name. To search again type a partial field
   name. ctrl-c to exit.`))

(defn main
  [& args]
  (when (nil? (get args 1))
    (print "Usage: cli.janet SF_OBJECT_NAME i.e. `janet cli.janet Lead`")
    (break))
  (set object-name (get args 1))
  (set metadata (describe object-name))
  (setup-search-data)
  (greeting)
  (while true (prompt)))
