module RcExample

using Plots, XLSX, DataFrames, Unitful
using GivEmExel, GivEmExel.SimpleArgParse # , GivEmExel.SavingResults
using NonlinearSolve, Suppressor
using Unitful: ϵ0

using GivEmExel.SavingResults: combine2df




include("RcExample_specific.jl")

# postproc = nothing # uncomment this line if you don't want a summary
export preproc, procsubset, postproc

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
export pp0, pps

include("precompile.jl")

end # module RcExample
