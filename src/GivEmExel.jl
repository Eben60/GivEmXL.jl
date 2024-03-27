module GivEmExel
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file, pick_multi_file, pick_folder

include("InternalArgParse/InternalArgParse.jl")

using .InternalArgParse

# using SimpleArgParse

export pick_file, @load_preference, @set_preferences!, @has_preference
export parse_cl_string
export repl
export emptyargs, prompt_and_parse, proc_ARGS, full_interact

export InternalArgParse

# temporary exports
export read_units, nt_skipmissing, merge_params, keys_skipmissing, merge_params, 
    parse_commandline, to_nt, get_xl, mergent

include("process_data.jl")
include("parse_ARGS.jl")
include("utils.jl")
include("repl.jl")
include("get_xl.jl")
include("interact.jl")

end
