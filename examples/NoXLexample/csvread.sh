#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJ_DIR="$SCRIPT_DIR/NoXLexample.jl/"
JLSCRIPT="$SCRIPT_DIR/NoXLexample.jl/src/csvread.jl"

julia --project="$PROJ_DIR" "$JLSCRIPT" $@