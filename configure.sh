#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "usage: ./configure.sh <path to elixir dir> <path to elixir site dir> \
        <path to ex_doc dir>"
    exit 1
fi

cat Makefile.in \
    | sed "s,ELIXIR_DIR =,ELIXIR_DIR = $1," \
    | sed "s,ELIXIR_LANG_DIR =,ELIXIR_LANG_DIR = $2," \
    | sed "s,EXDOC_DIR =,EXDOC_DIR = $3," \
    > Makefile
