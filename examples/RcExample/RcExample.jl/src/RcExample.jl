module RcExample

using GivEmExel, YAArgParser
using GivEmExel: combine2df
using Plots, XLSX, DataFrames, Unitful
using Unitful: ϵ0
using EasyFit: fitexp

include("RcExample_specific.jl")

# postproc = nothing # uncomment this line if you don't want a summary

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
export preproc, procsubset, postproc

include("precompile.jl")

end # module RcExample
