#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
JLSCRIPT="$SCRIPT_DIR/RcExample.jl/src/instantiate.jl"

julia $JLSCRIPT $@