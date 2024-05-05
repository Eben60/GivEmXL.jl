using GivEmExel
using GivEmExel.InternalArgParse

include("prompt2-init.jl")


pps = (;gen_options, spec_options, exelfile_prompt, next_file)

fi = complete_interact(pp0, pps, demo_fn; getexel=true, getdata=(; dialogtype = :single))

# prompt_and_parse(pp)