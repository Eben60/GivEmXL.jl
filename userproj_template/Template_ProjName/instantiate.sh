#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
JLSCRIPT="$SCRIPT_DIR/Template_ProjName.jl/src/instantiate.jl"

julia "$JLSCRIPT" $@