#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
JLSCRIPT="$SCRIPT_DIR/src/tmp2-main.jl"

julia --project=$SCRIPT_DIR $JLSCRIPT $@