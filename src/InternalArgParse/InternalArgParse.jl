module InternalArgParse

using OrderedCollections: OrderedDict
using Base: shell_split

kwargssubset(allargs, keyssubset) = NamedTuple(k => allargs[k] for k in keyssubset if haskey(allargs, k))
kwargssubset(allargs, t::Type) = kwargssubset(allargs, fieldnames(t))

function initparser(;kwargs...)
    iargs = kwargssubset(kwargs, InteractiveUsage)
    interactive = InteractiveUsage(; iargs...)
    apargs = kwargssubset(kwargs, ArgumentParser)
    return ArgumentParser(; interactive, apargs...)
end

export ArgumentParser, InteractiveUsage,
    add_argument!, add_example!, generate_usage!, help, parse_args!, 
    get_value, set_value!, colorize, getcolor, 
    colorprint, args_pairs, 
    validate, AbstractValidator, StrValidator, RealValidator,
    shell_split

export initparser

include("validator.jl")
include("datastructures.jl")
include("functions.jl")
include("utilities.jl")

end # module SimpleArgParse
