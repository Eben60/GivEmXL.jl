"Key-value store mapping from colors to ANSI codes. An internal constant."
ANSICODES::Base.ImmutableDict{String,Int} = Base.ImmutableDict(
    "black"   => 30,
    "red"     => 31,
    "green"   => 32,
    "yellow"  => 33,
    "blue"    => 34,
    "magenta" => 35,
    "cyan"    => 36,
    "white"   => 37,
    "default" => 39
)

"""
    colorize(text; color, background, bright) → ::String

Colorize strings or backgrounds using ANSI codes and escape sequences.

| Color    | Example|  Text| Background| Bright text| Bright background |
| ---------|--------| -----|-----------|------------|-------------------|
| Black    | Black  |  30  | 40        | 90         | 100               |
| Red      | Red    |  31  | 41        | 91         | 101               |
| Green    | Green  |  32  | 42        | 92         | 102               |
| Yellow   | Yellow |  33  | 43        | 93         | 103               |
| Blue     | Blue   |  34  | 44        | 94         | 104               |
| Magenta  | Magenta|  35  | 45        | 95         | 105               |
| Cyan     | Cyan   |  36  | 46        | 96         | 106               |
| White    | White  |  37  | 47        | 97         | 107               |
| Default  |        |  39  | 49        | 99         | 109               |

# Arguments
- `text::AbstractString`: the UTF-8/ASCII text to colorize.

# Keywords
- `color::AbstractString="default"`: the standard ANSI name of the color.
- `background::Bool=false`: flag to select foreground or background color.
- `bright::Bool=false`: flag to select normal or bright text.

Function `colorize` is internal.
"""
function colorize(text::AbstractString; color::AbstractString="default", background::Bool=false, bright::Bool=false)
    code::Int8 = ANSICODES[color]
    background && (code += 10)
    bright && (code += 60)
    code_string::String = string(code)
    return "\033[" * code_string * "m" * text * "\033[0m"
end

"""
    getcolor(parser::ArgumentParser, color=nothing)  → color::String

Returns `color` in case second arg is defined, otherwise the color defined in `parser`, or "default".

Function `getcolor` is public, not exported.
"""
function getcolor(parser::ArgumentParser, color=nothing) 
    !isnothing(color) && return color   
    return isnothing(parser.color) ? 
        "default" : parser.color
end

"""
    colorprint(text, color::AbstractString="default", newline=true; background=false, bright=false) → nothing
    colorprint(text, parser::ArgumentParser, newline=true; background=false, bright=false) → nothing

Print colored text into stdout. For color table, see help to internal `colorize` function. 
If second arg is an `ArgumentParser`, uses color as defined within, if any, otherwise uses `default`.

Function `colorprint` is exported.
"""
function colorprint(text, color="default", newline=true; background=false, bright=false) 
    print(colorize(text; color, background, bright))
    newline && println()
end

colorprint(text, parser::ArgumentParser, newline=true; background=false, bright=false) = 
    colorprint(text, getcolor(parser), newline; background, bright)

argpair(s, parser) = Symbol(s) => get_value(parser, s)

_keys(parser::ArgumentParser) = [arg2strkey(v.args.long) for v in values(parser.kv_store)]

canonicalname(argf::ArgForms) = lstrip((isempty(argf.long) ? argf.short : argf.long), '-')
canonicalname(argvs::ArgumentValues) = canonicalname(argvs.args)

"""
    args_pairs(parser::ArgumentParser; excl::Union{Nothing, Vector{String}}=nothing) → ::Vector{Pair{Symbol, Any}}

Return vector of pairs `argname => argvalue` for all arguments except listed in `excl`.
    If argument has both short and long forms, the long one is used. Returned value can 
    be e.g. passed as `kwargs...` to a function processing the parsed data, converted to 
    a `Dict` or `NamedTuple`.

Function `args_pairs` is exported.
"""
function args_pairs(parser::ArgumentParser; excl=nothing)
    isnothing(excl) && (excl=[])
    args = collect(values(parser.kv_store))
    filter!(x -> !isnothing(x.value), args)
    filter!(x -> !(lstrip(x.args.long, '-') in excl) , args)
    return [Symbol(canonicalname(a)) => a.value for a in args]
end

positional_args(parser::ArgumentParser) = [x for x in values(parser.kv_store) if x.positional]

throw_on_exception(::Nothing) = true
throw_on_exception(parser::ArgumentParser) = throw_on_exception(parser.interactive)
throw_on_exception(x::InteractiveUsage) = x.throw_on_exception

"""
    haskey(parser::ArgumentParser, key::AbstractString) → ::Bool
    haskey(parser::ArgumentParser, key::Integer) → ::Bool
"""
Base.haskey(parser::ArgumentParser, key::AbstractString) = haskey(parser.arg_store, arg2strkey(key))   
Base.haskey(parser::ArgumentParser, key::Integer) = haskey(parser.kv_store, key)

"""
    shell_split(s::AbstractString) → String[]

Split a string into a vector of args.

`shell_split` is in internal function of `Base`. It is re-exported.

# Examples
```julia-repl
julia> shell_split("--foo 3 -b bar")
4-element Vector{String}:
 "--foo"
 "3"
 "-b"
 "bar"
```
"""
function shell_split end
