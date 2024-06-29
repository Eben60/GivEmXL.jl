module GivEmExel
using SimpleArgParse2
using JuliaInterpreter
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file, pick_multi_file, pick_folder
using PrecompileTools, Compat


isplot(::Any) = false
save_plot(p::Any, fl) = Error("Saving plots not implemented for $(typeof(p)). You may want to implement your own method for GivEmExel: save_plot")

@compat public isplot, save_plot

include("process_data.jl")
include("get_files.jl")
include("interact.jl")
include("SavingResults.jl")


using SimpleArgParse2: get_value, getcolor

export complete_interact, proc_n_save, read_xl_paramtables, exper_paramsets

@compile_workload begin
    s2unit("100m/s^2")
end

end
