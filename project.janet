(declare-project
  :name "Salesforce Inspector"
  :description "CLI tool to inspect SF data model"
  :dependencies ["https://github.com/janet-lang/spork"
                 "https://github.com/shofetim/salesforce"]
  :author "Jordan Schatz"
  :license "ISC"
  :version "0.1"
  :url "https://jordanschatz.com/projects/salesforce-inspector"
  :repo "https://github.com/shofetim/salesforce-inspector")

(declare-executable
  :name "sf-inspect"
  :entry "src/main.janet")
