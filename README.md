# README

A fast way to find Salesforce field metadata

## Prerequisites

This (sfmt) is built on top of [fzf](https://github.com/junegunn/fzf) which you
will need to install first.

## Installation

If you are on (x86_64) Linux you can simply download the
[build/sfmt](./build/sfmt) binary and place it somewhere in your $PATH.

If you are on another OS, then you will need to first install
[Janet](https://janet-lang.org/) and [JPM](https://janet-lang.org/docs/jpm.html)
and build the binary for your OS.

Cross platform builds are planned in the near future.

## Use

First, set the following environment variables so sfmt knows how to connect to
your org:

```sh
export SF_PASSWORD="XXXXXXXXXXXX"
export SF_TOKEN="XXXXXXXXXXXXXXXXXXXXXXXX"
export SF_USERNAME="you@example.com"
export SF_URL="https://XXXXXXX.my.salesforce.com"
```

A handy way of doing this is to record them in a file named after the org, such
as:

- org-A.sh
- org-B.sh

and then `source org-A.sh` to connect to that org `source org-B.sh` to connect
to another, etc.

Then we need to fetch an up to date copy of the object and field data from the
org. To do so run `sfmt fetch` depending on your org's metadata size, network
speed, etc. this can take several minutes. sfmt will store a cached copy of the
metadata to make future actions fast.

If you want to know when an org was last fetched, use `sfmt last-synced`. To
refresh the local cache, run `sfmt fetch` again.

Once you have the data, then run the `./inspect.sh` script. This will display
all fields in the org, in object-name.field-name format. You can then use [fzf's
search syntax](https://github.com/junegunn/fzf?tab=readme-ov-file#search-syntax)
to find the field you are interested in, alt-w will copy the highlighted field's
name to the clipboard.





