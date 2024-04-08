module InternalArgParse

export ArgumentParser, InteractiveUsage,
    add_argument!, add_example!, generate_usage!, help, parse_args!, 
    get_value, set_value!, colorize, 
    colorprint, args_pairs, 
    validate, AbstractValidator, StrValidator, RealValidator

using OrderedCollections: OrderedDict

include("validator.jl")
include("datastructures.jl")
include("functions.jl")
include("utilities.jl")

end # module SimpleArgParse
