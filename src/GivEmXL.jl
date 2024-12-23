"""
    Package GivEmXL v$(pkgversion(GivEmXL))

This package helps you in creating redistributable Julia packages for "somewhat interactive" use, 
which optionally use files in Excel format for data input and output. 

Docs under https://eben60.github.io/GivEmXL.jl/
$(isnothing(get(ENV, "CI", nothing)) ? ("\n" * "Package local path: " * pathof(GivEmXL)) : "")
"""
module GivEmXL

using YAArguParser
using YAArguParser: get_value, getcolor

using Unitful, DataFrames, XLSX, Preferences # , Missings
using NativeFileDialog: pick_file, pick_multi_file, pick_folder
using JuliaInterpreter, PrecompileTools, Compat
using TOML
using UUIDs


isplot(::Any) = false
save_plot(p::Any, fl) = error("Saving plots not implemented for $(typeof(p)). You may want to implement your own method for GivEmXL: save_plot")

include("process_data.jl")
include("get_files.jl")
include("interact.jl")
include("SavingResults.jl")
include("create_user_proj.jl")

export complete_interact, exper_paramsets, proc_n_save, read_xl_paramtables

@compat public combine2df, get_data, get_xl, makeproj, merge_params, out_paths, parse_cl_string, proc_ARGS, 
    proc_data, prompt_and_parse, save_all_plots, save_dfs, save_results, saveplots, write_errors, write_xl_tables
    

@compat public isplot, save_plot # used for extensions

@compile_workload begin
    s2unit("100m/s^2")
end

end
