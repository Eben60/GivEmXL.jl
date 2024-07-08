module Template_ProjName

using GivEmExel, YAArguParser
using GivEmExel: combine2df
using Plots, XLSX, DataFrames, Unitful
using Unitful: ϵ0
using EasyFit: fitexp

include("Template_ProjName_specific.jl")

# postproc = nothing # uncomment this line if you don't want a summary

prompt = "Template_ProjName> "
promptcolor = "cyan"
batchfilename = "template_user_scriptname"

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

end # module Template_ProjName
