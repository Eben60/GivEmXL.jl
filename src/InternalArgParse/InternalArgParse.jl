module InternalArgParse

using OrderedCollections: OrderedDict
using Base: shell_split

export ArgumentParser, InteractiveUsage,
    add_argument!, add_example!, generate_usage!, help, parse_args!, 
    get_value, set_value!, colorize, 
    colorprint, args_pairs, getcolor,
    validate, AbstractValidator, StrValidator, RealValidator,
    shell_split

include("validator.jl")
include("datastructures.jl")
include("functions.jl")
include("utilities.jl")

end # module SimpleArgParse
