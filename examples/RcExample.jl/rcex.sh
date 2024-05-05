#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
JLSCRIPT="$SCRIPT_DIR/src/rcex.jl"

julia --project=$SCRIPT_DIR $JLSCRIPT $@