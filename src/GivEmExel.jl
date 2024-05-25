module GivEmExel
using JuliaInterpreter
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file, pick_multi_file, pick_folder
using PrecompileTools


isplot(::Any) = false
save_plot(p::Any, fl) = Error("Saving plots not implemented for $(typeof(p)). You may want to implement your own method for GivEmExel.SavingResults: save_plot")


include("InternalArgParse/SimpleArgParse.jl")

using .SimpleArgParse
using .SimpleArgParse: get_value, getcolor


# export SimpleArgParse
export complete_interact, merge_params
# export SavingResults
# export prepare_xl, out_paths, write_errors, saveplots

# function prepare_xl() end
# function out_paths() end
# function write_errors() end
# function saveplots() end

export read_xl_paramtables, exper_paramsets

include("process_data.jl")
include("get_files.jl")
include("interact.jl")
include("SavingResults.jl")


@compile_workload begin
    s2unit("100m/s^2")
end

end
