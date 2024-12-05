#!/bin/sh

source creds.sh

find . -name '*.janet' | entr -c janet src/main.janet
