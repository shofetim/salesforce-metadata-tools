(import sqlite3 :as sql)
(import ./util)

(var db nil)

(def- schema `
  create table if not exists orgs (
     id integer primary key,
     name text unique,
     synced datetime default current_timestamp
  );

  create table if not exists objects (
    id integer primary key,
    org integer,
    label text,
    name text,
    foreign key ("org") references "orgs" ("id") on delete cascade,
    unique (org, name)
  );

  create table if not exists fields (
    id integer primary key,
    object integer,
    calculatedFormula text,
    precision integer,
    scale integer,
    calculated boolean,
    extraTypeInfo text,
    digits integer,
    length integer,
    referenceTo text,
    autoNumber boolean,
    nameField boolean,
    picklistValues text,
    defaultValue text,
    type text,
    inlineHelpText text,
    name text,
    label text,
    foreign key ("object") references "objects" ("id") on delete cascade,
    unique(object, name)
  );`)

(defn- db-name []
  (let [default-directory (or (os/getenv "HOME") # linux
                              (os/getenv "USERPROFILE") # windows
                              (when-let [drive (os/getenv "HOMEDRIVE")
                                         home-path (os/getenv "HOMEPATH")]
                                (string drive home-path)))
        default (string default-directory "/.sfmt.db")
        override (os/getenv "SFMT_DBNAME")]
    (or override default)))

(defn query
  "Query SQLite"
  [sql &opt params]
  (if params
    (sql/eval db sql params)
    (sql/eval db sql)))

(defn last-synced [name]
  (get-in (query "select synced from orgs where name = ?" [name])
          [0 :synced] 0))

(defn get-field [name]
  (let [org-name (util/org-name)
        [object-name field-name] (util/split-fieldname name)
        sql `select fields.*
             from fields
             left join objects on fields.object = objects.id
             left join orgs on objects.org = orgs.id
             where orgs.name = ?
                   and objects.name = ?
                   and fields.name = ?`]
    (first (query sql [org-name object-name field-name]))))

(defn get-object [id]
  (first (query `select * from objects where id = ?` [id])))

(defn get-object-fields [object-id]
  (query `select * from fields where object = ?` [object-id]))

(defn get-org []
  (first (query `select * from orgs where name = ?` [(util/org-name)])))

(defn get-all-objects [org-id]
  (query `select * from objects where org = ?` [org-id]))

(defn format-picklist-values [vals]
  (string/join (map |($ "label") (filter |($ "active") vals)) ", "))

(defn- _save [table record]
  (let [cols (keys record)
        names (string/join cols `","`)
        col-count (length cols)
        params (string/join (array/new-filled col-count "?") ",")
        sql (string/format `insert into "%s" ("%s") values (%s) returning *`
                           table names params)
        vals (map (fn [col]
                    (case col
                      "referenceTo" (string/join (record col) ", ")
                      "picklistValues" (format-picklist-values (record col))
                      (record col))) cols)]
    (first (query sql vals))))

(defn save [object fields]
  (let [org-id ((get-org) :id)
        object (merge {:org org-id} object)
        saved-object (_save "objects" object)
        object-id (saved-object :id)]
    (each field fields
      (_save "fields" (merge {:object object-id} field)))))

(defn save-org [] (_save "orgs" {:name (util/org-name)}))

(defn delete-org [] (query `delete from orgs where name = ?` [(util/org-name)]))

(defn open []
  (let [path (db-name)]
    (set db (sql/open path))
    (query "pragma journal_mode = DELETE")
    (query "pragma foreign_keys = ON")
    (query schema)))

(defn close [] (sql/close db))
