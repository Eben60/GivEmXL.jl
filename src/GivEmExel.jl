module GivEmExel
using JuliaInterpreter
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file, pick_multi_file, pick_folder
using PrecompileTools


isplot(::Any) = false
save_plot(p::Any, fl) = Error("Saving plots not implemented for $(typeof(p)). You may want to implement your own method for GivEmExel.SavingResults: save_plot")


include("InternalArgParse/SimpleArgParse.jl")

include("process_data.jl")
include("get_files.jl")
include("interact.jl")
include("SavingResults.jl")

using .SimpleArgParse
using .SimpleArgParse: get_value, getcolor

# export SimpleArgParse
export complete_interact, merge_params
export read_xl_paramtables, exper_paramsets

using .SavingResults
# export SavingResults
export proc_n_save

@compile_workload begin
    s2unit("100m/s^2")
end

end
