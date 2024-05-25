module RcExample

using Plots, XLSX, DataFrames, Unitful
using GivEmExel, GivEmExel.SavingResults, GivEmExel.SimpleArgParse
using NonlinearSolve, Suppressor
using Unitful: ϵ0


postproc = nothing

include("RcExample_specific.jl")
export procwhole, procsubset, postproc

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
