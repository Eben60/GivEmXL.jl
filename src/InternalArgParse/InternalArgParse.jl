module InternalArgParse

using OrderedCollections: OrderedDict
using Base: shell_split


# throw_on_exception::Bool=false
# color::String = "default"
# introduction::String = ""
# prompt::String = "> "

kwargssubset(allargs, keyssubset) = NamedTuple(k => allargs[k] for k in keyssubset)

function initparser(;kwargs...)
    interactive = [:throw_on_exception, :color, :introduction, :prompt]
    kwkeys = keys(kwargs)
    iakeys = interactive ∩ kwkeys
    apkeys = setdiff(kwkeys, iakeys)

    iargs = kwargssubset(kwargs, iakeys)
    apargs = kwargssubset(kwargs, apkeys)

    interactive = InteractiveUsage(; iargs...)
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
