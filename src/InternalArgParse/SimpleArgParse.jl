module SimpleArgParse

using Compat
using OrderedCollections: OrderedDict
import Base.shell_split

# types
export ArgForms, ArgumentParser, ArgumentValues, InteractiveUsage,
    RealValidator, StrValidator

# functions
export shell_split, add_argument!, add_example!, args_pairs, colorprint, 
    help, parse_args!, validate, initparser

# in effect in Julia ≥ v1.11
@compat public AbstractValidator # types
@compat public generate_usage!, get_value, getcolor, parse_arg, set_value! # functions


kwargssubset(allargs, keyssubset) = NamedTuple(k => allargs[k] for k in keyssubset if haskey(allargs, k))
kwargssubset(allargs, t::Type) = kwargssubset(allargs, fieldnames(t))

function initparser(;kwargs...)
    iargs = kwargssubset(kwargs, InteractiveUsage)
    interactive = InteractiveUsage(; iargs...)
    apargs = kwargssubset(kwargs, ArgumentParser)
    return ArgumentParser(; interactive, apargs...)
end


include("validator.jl")
include("datastructures.jl")
include("functions.jl")
include("utilities.jl")

include("precompile.jl")

end # module SimpleArgParse
