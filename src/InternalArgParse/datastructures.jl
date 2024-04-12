
"""
    ArgForms

Command-line arguments, short and long forms.

# Fields
- `short::String`
- `long::String`
"""
struct ArgForms
    short::String
    long::String
end

"""
    ArgumentValues

Command-line argument values.

# Fields
- `const args::ArgForms`
- `value::Any`
- `const type::Type = Any`
- `const positional::Bool = false`
- `const description::String = ""`
- `const validator::Union{AbstractValidator, Nothing} = nothing`
"""
@kwdef mutable struct ArgumentValues
    const args::ArgForms
    value::Any
    const type::Type = Any
    const positional::Bool = false
    const description::String = ""
    const validator::Union{AbstractValidator, Nothing} = nothing
end

"""
    InteractiveUsage

# Fields  
- `throw_on_exception = false`: immediately throw on exception if `true`, 
    or process error downstream if `false` (interactive use)
- `color::String = "default"`: output color (see `colorize` function)
- `introduction::String = ""`: explanation or introduction to be shown before prompt on a separate line
- `prompt::String = "> "`
"""
@kwdef struct InteractiveUsage
    throw_on_exception::Bool=false
    color::String = "default"
    introduction::String = ""
    prompt::String = "> "
end

"""
    ArgumentParser

Command-line argument parser with numkey-value stores and attributes.

# Fields
## stores
- `kv_store::OrderedDict{UInt16,ArgumentValues} = OrderedDict()`: `numkey => value` 
- `arg_store::OrderedDict{String,UInt16} = OrderedDict()`: numkey-value store: `arg => numkey`
- `lng::UInt16 = 0`: counter of stored args
## attributes
- `filename::String = ""`: file name
- `description::String = ""`: description
- `authors::Vector{String} = String[]`: name of author(s): First Last <first.last@email.address>
- `documentation::String = ""`: URL of documentations
- `repository::String = ""`: URL of software repository
- `license::String = ""`: name of license
- `usage::String = ""`: usage/help message
- `examples::Vector{String} = String[]`: usage examples
- `add_help::Bool = false`: flag to automatically generate a help message
- `interactive::Union{Nothing, InteractiveUsage} = nothing`: interactive usage attributes (see `InteractiveUsage`)
"""
@kwdef mutable struct ArgumentParser
    kv_store::OrderedDict{UInt16,ArgumentValues} = OrderedDict()
    arg_store::OrderedDict{String,UInt16} = OrderedDict()
    lng::UInt16 = 0
    filename::String = ""
    description::String = ""
    authors::Vector{String} = String[]
    documentation::String = ""
    repository::String = ""
    license::String = ""
    usage::String = ""
    examples::Vector{String} = String[]
    add_help::Bool = false
    interactive::Union{Nothing, InteractiveUsage} = nothing
end
