module NoXLexample

using GivEmXL, YAArguParser

include("NoXLexample_specific.jl")

prompt = "NoXLexample> "
promptcolor = "cyan"
batchfilename = "csvread"

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

end # module NoXLexample
