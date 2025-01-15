(import spork/misc)
(import salesforce :as sf)
(import ./db)
(import ./util)

(def- properties-we-care-about
  ["calculatedFormula" "precision" "scale" "calculated"
   "extraTypeInfo" "digits" "length" "referenceTo" "autoNumber"
   "nameField" "picklistValues" "defaultValue" "type" "inlineHelpText"
   "name" "label"])

(defn- sf-list-objects []
  (let [objects (filter
                 (fn [{"deprecatedAndHidden" deprecatedAndHidden "isInterface" isInterface
                       "layoutable" layoutable "queryable" queryable "retrieveable" retrieveable
                       "searchable" searchable "triggerable" triggerable }]
                   (and (= deprecatedAndHidden false)
                        (= isInterface false)
                        (= layoutable true)
                        (= queryable true)
                        (= retrieveable true)
                        (= searchable true)
                        (= triggerable true)))
                 ((sf/describe-all) "sobjects"))]
    (map (fn [{"label" label "name" name}] {:label label :name name}) objects)))

(defn sf-object-fields [name]
  (let [res (sf/describe name)]
    (map |(misc/select-keys $ properties-we-care-about) (res "fields"))))

(defn all-fields []
  (let [org (db/get-org)
        objects (db/get-all-objects (org :id))]
    (each object objects
      (map |(print (util/format-field (object :name) ($ :name)))
           (db/get-object-fields (object :id))))))

(defn- fetch []
  (when (db/get-org) (db/delete-org))
  (db/save-org)
  (each object (sf-list-objects)
    (db/save object (sf-object-fields (object :name)))))

(defn- last-synced [] (print (get (db/get-org) :synced "Never Synced")))

(defn- field [field-name]
  (let [field (db/get-field (string/slice field-name 1))
        object (db/get-object (field :object))
        {:name name :label label :type type
         :inlineHelpText inlineHelpText :picklistValues picklistValues} field]
    (printf `%s
              Name: %s
              Label: %s
              Type: %s
              Help Text: %s
              Picklist Values: %s`
            (object :name) name label type inlineHelpText picklistValues)))

(defn- help []
  (printf `sfmt help — This help text
          sfmt last-synced — Get the date the last time we synced metadata for this org
          sfmt fetch — Fetch metadata and update local cache
          sfmt all-fields — List all fields
          sfmt field FIELDNAME — details for fields`))

(defn main [& args]
  (db/open)
  (case (get args 1)
    "last-synced" (last-synced)
    "fetch" (fetch)
    "all-fields" (all-fields)
    "field" (field (get args 2))
    (help))
  (db/close))
