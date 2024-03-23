using GivEmExel
using SimpleArgParse

include("prompt2-init.jl")


pps = (;gen_options)

fi = full_interact(pp0, pps)

# prompt_and_parse(pp)