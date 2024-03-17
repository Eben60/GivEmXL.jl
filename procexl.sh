#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
JLSCRIPT="$SCRIPT_DIR/src/maintest.jl"

julia $JLSCRIPT "$@"