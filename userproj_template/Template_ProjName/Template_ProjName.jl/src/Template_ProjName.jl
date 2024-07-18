module Template_ProjName

using GivEmExel, YAArguParser

include("Template_ProjName_specific.jl")

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
