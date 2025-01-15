(declare-project
  :name "Salesforce Metadata Tools"
  :description "CLI tool for SF metadata"
  :dependencies ["https://github.com/janet-lang/spork"
                 "https://github.com/shofetim/salesforce"
                 "https://github.com/shofetim/sqlite3"]
  :author "Jordan Schatz"
  :license "ISC"
  :version "0.1"
  :url "https://jordanschatz.com/projects/salesforce-inspector"
  :repo "https://github.com/shofetim/salesforce-inspector")

(declare-executable
  :name "sfmt"
  :entry "src/main.janet")
