#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJ_DIR="$SCRIPT_DIR/Template_ProjName.jl/"
JLSCRIPT="$SCRIPT_DIR/Template_ProjName.jl/src/template_user_scriptname.jl"

julia --project=$PROJ_DIR $JLSCRIPT $@