module GivEmExel
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file

export pick_file, @load_preference, @set_preferences!, @has_preference
export repl

export read_units, nt_skipmissing, merge_params, process_data, keys_skipmissing, merge_params

include("process_data.jl")
include("repl.jl")

end
