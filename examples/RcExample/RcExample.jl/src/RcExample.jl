module RcExample

using Plots, XLSX, DataFrames, Unitful
using GivEmExel, GivEmExel.SimpleArgParse
using NonlinearSolve, Suppressor
using Unitful: ϵ0

using GivEmExel: combine2df




include("RcExample_specific.jl")

# postproc = nothing # uncomment this line if you don't want a summary
# export preproc, procsubset, postproc

prompt = "RcExample> "
promptcolor = "cyan"
batchfilename = "rcex"

@static if Sys.iswindows()
    ext = ".bat"
else
    ext = ".sh"
end

batchfilename *= ext

include("init_cli_options.jl")

process_and_save(; kwargs...) = proc_n_save(preproc, procsubset, postproc; kwargs...)
export pp0, pps, process_and_save

include("precompile.jl")

end # module RcExample
