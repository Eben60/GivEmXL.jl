module GivEmExel
using Unitful, DataFrames, XLSX
using NativeFileDialog: pick_file
export pick_file, repl

export read_units, nt_skipmissing, merge_params, process_data, keys_skipmissing, merge_params

include("process_data.jl")
include("repl.jl")

end
