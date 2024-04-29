module GivEmExel
using Unitful, DataFrames, XLSX, Preferences # , Plots
using NativeFileDialog: pick_file, pick_multi_file, pick_folder

include("InternalArgParse/InternalArgParse.jl")

using .InternalArgParse
# using SimpleArgParse


export InternalArgParse
export full_interact, merge_params
# export SavingResults
export prepare_xl, out_paths, write_errors, saveplots

function prepare_xl() end
function out_paths() end
function write_errors() end
function saveplots() end

export read_xl_paramtables, exper_paramsets

include("process_data.jl")
include("get_files.jl")
include("interact.jl")
# include("saving_results.jl")

end
