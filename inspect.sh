#!/bin/sh

sfmt all-fields |
    fzf --bind 'ctrl-r:reload(sfmt all-fields)' \
        --bind 'alt-w:execute-silent(echo {} | wl-copy)' \
        --preview 'sfmt field {}' \
        --header 'CTRL-R to reload, ALT-W to copy' \
        --layout=reverse
