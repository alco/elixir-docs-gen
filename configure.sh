#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "usage: ./configure.sh <path to elixir site dir>"
    exit 1
fi

cat Makefile.in \
    | sed "s,ELIXIR_LANG_DIR =,ELIXIR_LANG_DIR = $1," \
    > Makefile
