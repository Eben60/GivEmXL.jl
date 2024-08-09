#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
JLSCRIPT="$SCRIPT_DIR/NoXLexample.jl/src/instantiate.jl"

julia "$JLSCRIPT" $@