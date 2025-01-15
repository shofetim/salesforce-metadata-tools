(defn org-name []
  (->> (get (os/environ) "SF_URL")
       (string/replace "https://" "")
       (string/split ".")
       (first)))

(defn split-fieldname [full-fieldname]
  (string/split "." (string full-fieldname)))

(defn format-field [object-name field-name]
  (string ":" object-name "." field-name))
