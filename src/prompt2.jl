using GivEmExel
using SimpleArgParse

include("prompt2-init.jl")


pps = (;gen_options, spec_options, next_file)

fi = full_interact(pp0, pps)

# prompt_and_parse(pp)