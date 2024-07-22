#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJ_DIR="$SCRIPT_DIR/RcExample.jl/"
JLSCRIPT="$SCRIPT_DIR/RcExample.jl/src/rcex.jl"

julia --project="$PROJ_DIR" "$JLSCRIPT" $@