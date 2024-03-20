using SimpleArgParse

# function parse_commandline()
#     s = ArgParseSettings()

#     @add_arg_table! s begin
#         "--plottype", "-p"
#             help = "plot type (must be accepted by Plots.jl)"
#             arg_type = String
#             default = "PNG"
#         "--otherargs", "-o"
#             help = "another option with an argument"
#     end

#     return parse_args(s)
# end

to_nt(d) = NamedTuple([(Symbol(k) => v) for (k,v) in d if !isnothing(v)])