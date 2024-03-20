module GivEmExel
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file

export pick_file, @load_preference, @set_preferences!, @has_preference
export parse_cl_string, argpair
export repl

# temporary exports
export read_units, nt_skipmissing, merge_params, process_data, keys_skipmissing, merge_params, 
    parse_commandline, to_nt

include("process_data.jl")
include("parse_ARGS.jl")
include("utils.jl")
include("repl.jl")

end
