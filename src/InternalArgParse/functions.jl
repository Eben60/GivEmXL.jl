"""
    args2vec(args::ArgForms) → ::Vector{String}

Extract struct members to vector of length 1 or 2.

Function `args2vec` is internal.
"""
args2vec(args::ArgForms) = filter!(x -> !isempty(x), [args.short, args.long])

"""
    arg2strkey(arg::AbstractString) → ::SubString

Argument to argument-store string key conversion by removing hypenation from prefix.

Function `arg2strkey` is internal.
"""
arg2strkey(arg) = lstrip(arg, '-')


"""
    add_argument!(parser::ArgumentParser, arg_short::String="", arg_long::String=""; kwargs...) → parser

# Arguments
- `parser::ArgumentParser`: ArgumentParser object instance.
- `arg_short::String=""`: short argument flag.
- `arg_long::String=""`: long argument flag.

# Keywords
- `type::Type=nothing`: type, the argument value to be parsed/converted into.
- `default::Any=nothing`
- `positional::Bool=false`
- `description::String=nothing`
- `validator::Union{AbstractValidator, Nothing}=nothing` 

Function `add_argument!` is exported
"""
function add_argument!(parser::ArgumentParser, arg_short::String="", arg_long::String="";
    type::Type=Any, positional=false, default=nothing, description::String="", validator=nothing)

    args::ArgForms = ArgForms(arg_short, arg_long)
    arg::String = !isempty(arg_long) ? arg_long : !isempty(arg_short) ? arg_short : ""
        isempty(arg) && throw(ArgumentError("Argument(s) missing. See usage examples.")) 

    haskey(parser.arg_store, arg2strkey(arg_short)) && error("Cannot add argument: Key $arg_short already present.")
    haskey(parser.arg_store, arg2strkey(arg_long)) && error("Cannot add argument: Key $arg_short already present.")

    parser.lng += 1
    numkey::UInt16 = parser.lng
    # map both argument names to the same numkey
    !isempty(arg_short) && (parser.arg_store[arg2strkey(arg_short)] = numkey)
    !isempty(arg_long)  && (parser.arg_store[arg2strkey(arg_long)]  = numkey)
    default = (type == Any) | isnothing(default) ? default : convert(type, default)
    (ok, default) = validate(default, validator)
    ok || throw(ArgumentError("invalid default value $default for arg $(canonicalname(args))")) 
    vals::ArgumentValues = ArgumentValues(args, default, type, positional, description, validator)
    parser.kv_store[numkey] = vals
    return parser
end

"""
    add_example!(parser::ArgumentParser, example::AbstractString) → parser

Function `add_example!` is exported.
"""
function add_example!(parser::ArgumentParser, example::AbstractString)
    push!(parser.examples, example)
    return parser
end

"""
    sort_args(parser::ArgumentParser) → (;pos_args, keyed_args, all_args)

Function `sort_args` is internal.
"""
function sort_args(parser)
    pos_args = ArgumentValues[]
    keyed_args = ArgumentValues[]

    for v in values(parser.kv_store)
        if v.positional
            push!(pos_args, v)
        else
            push!(keyed_args, v)
        end      
    end
    all_args = [pos_args; keyed_args]
    return (;pos_args, keyed_args, all_args)
end

"""
    argument_usage(v::ArgumentValues) → (; u=args_usage, o=options)

Function `sort_args` is internal.
"""
function argument_usage(v)
    isrequired = isnothing(v.value)
    args_vec::Vector{String} = args2vec(v.args)
    # example: String -> "<STRING>"
    type::String = v.type != Bool ? string(" ", join("<>", uppercase(string(v.type)))) : ""
    # example: (i,input) -> "[-i|--input <STRING>]"
    args_usage::String = v.positional ? type : string(join(hyphenate.(args_vec), "|"), type)
    !isrequired && (args_usage = join("[]", args_usage))
    # example: (i,input) -> "-i, --input <STRING>"
    tabs::String = v.type != Bool ? "\t" : "\t\t"
    args_options::String = string("\n  ", join(hyphenate.(args_vec), ", "), type, tabs, v.description)
    v.positional && (args_options *= "\t (positional arg)")
    options = args_options
    return (; u=args_usage, o=options)
end

"""
    generate_usage!(parser::ArgumentParser) → ::String

Usage/help message generator.

# Example of generated text
Usage: main.jl --input <PATH> [--verbose] [--problem] [--help]

A Julia script with command-line arguments.

Options:
  -i, --input <PATH>    Path to the input file.
  -v, --verbose         Enable verbose message output.
  -p, --problem         Print the problem statement.
  -h, --help            Print this help message.

Examples:
  \$ julia main.jl --input dir/file.txt --verbose
  \$ julia main.jl --help
"""
function generate_usage!(parser::ArgumentParser)
    usage::String = "Usage: $(parser.filename)"
    options::String = "Options:"

    (;all_args) = sort_args(parser)

    for v::ArgumentValues in all_args
        (; u, o) = argument_usage(v)
        usage *= " " * u
        options *= o
    end

    examples::String = string("Examples:", join(string.("\n  \$ ", parser.examples)))
    generated::String = """

    $(usage)

    $(parser.description)

    $(options)

    $(examples)
    """
    parser.usage = generated
    return parser.usage
end

"""
    help(parser::ArgumentParser; color::Union{AbstractString, Nothing}) → nothing

Print usage/help message.
"""
function help(parser::ArgumentParser; color=nothing)
    color = getcolor(parser, color)
    colorprint(parser.usage, color)
    return nothing
end

"""
    update_val!(parser::ArgumentParser, numkey::Integer, value) → parser

Function `update_val!` is internal
"""
function update_val!(parser, numkey, value)
    # extract default value and update given an argument value
    vals::ArgumentValues = parser.kv_store[numkey]
    # type cast value into tuple index 1
    value = try
        value = vals.type == Any ? value : _parse(vals.type, value)
    catch e
        e isa ArgumentError && return _error(throw_on_exception(parser), "cannot parse $value into $(vals.type)")
    end

    return set_value!(parser, numkey, value)
end

"""
    parse_args!(parser::ArgumentParser; cli_args=nothing) → ::Union{ArgumentParser, Exception}

Parses arguments, validates them and stores the updated values in the parser. 

# Keywords
- `cli_args::Union{Vector{AbstractString}, Nothing}=nothing`: if the `cli_args` not provided, 
    parses the command line arguments `ARGS`. Otherwise accepts equivalent `Vector` of `String`s,
    e.g. `["--foo", "FOO", "-i", "1"]`

# Throws
- `Exception`: depending on the value of `parser.interactive`, in case of non-valid 
    args vector, the function will either throw imediately, or return `e <: Exception` to be 
    processed downstream.

Function `parse_args!` is exported.
"""
function parse_args!(parser::ArgumentParser; cli_args=nothing)
    isnothing(cli_args) && (cli_args=ARGS)
    if parser.add_help && !haskey(parser, "help")
        add_argument!(parser, "-h", "--help", type=Bool, default=false, description="Print the help message.")
        generate_usage!(parser)
    end
    parser.filename = PROGRAM_FILE
    n::Int64 = length(cli_args)
    posargs = positional_args(parser)

    nextarg = 1
    posargs_exhausted = false

    for (i, pa) in pairs(posargs)
        isempty(cli_args) && (posargs_exhausted = true)
        posargs_exhausted || (value = cli_args[i])
        if (!posargs_exhausted && !startswith(value, '-'))
            argkey = canonicalname(pa)
            numkey = parser.arg_store[argkey]
            uv = update_val!(parser, numkey, value)
            uv isa Exception && return uv
            nextarg += 1
        else
            posargs_exhausted = true
            isnothing(pa.value) && return _error(throw_on_exception(parser), "Value for positional argument $(canonicalname(pa)) not supplied")
        end
    end

    for i::Int64 in nextarg:length(cli_args)
        arg::String = cli_args[i]
        argkey::String = arg2strkey(arg)
        if startswith(arg, "-")
            !haskey(parser.arg_store, argkey) && return _error(throw_on_exception(parser), "Argument not found: $(arg). Call `add_argument` before parsing.")
            numkey::UInt16 = parser.arg_store[argkey]
            !haskey(parser.kv_store, numkey) && return _error(throw_on_exception(parser), "Key not found for argument: $(arg)"; excp=ErrorException)
        else
            continue
        end
        # if next iteration is at the end or is an argument, treat current argument as flag/boolean
        # otherwise, capture the value and skip iterating over it for efficiency
        if (i + 1 > n) || startswith(cli_args[i+1], "-")
            value = true
        elseif (i + 1 <= n)
            value = cli_args[i+1]
            i += 1
        else
            return _error(throw_on_exception(parser), "Value failed to parse for arg: $(arg)")
        end
        uv = update_val!(parser, numkey, value)
        uv isa Exception && return uv
    end
    return parser
end


"""
    get_value(parser, arg) → value::Any

Get argument value from parser. 

# Arguments
- `parser::ArgumentParser`: ArgumentParser object instance.
- `arg::AbstractString=""`: argument name, e.g. `"-f"`, `"--foo"`.

# Throws
- `Exception`: depending on the value of `throw_on_exception(parser)`, if the argument not 
    found, the function will either throw imediately, or return `e <: Exception` to be 
    processed downstream.

Function `get_value` is exported.
"""
function get_value(parser::ArgumentParser, arg::AbstractString)
    argkey::String = arg2strkey(arg)
    !haskey(parser.arg_store, argkey) && return _error(throw_on_exception(parser), "Argument not found: $(arg). Run `add_argument` first.")
    numkey::UInt16 = parser.arg_store[argkey]
    value::Any = haskey(parser.kv_store, numkey) ? parser.kv_store[numkey].value : nothing
    return value
end

"""
    hyphenate(argname::AbstractString) → ::String

Prepend hyphenation back onto argument after stripping it for the argument-store numkey.

Function `hyphenate` is internal.
"""
function hyphenate(argname::AbstractString)
    strkey::String = arg2strkey(argname)  # supports "foo" or "--foo" argument form
    result::String = length(strkey) == 1 ? "-" * strkey : "--" * strkey
    return result
end

"""
    set_value!(parser::ArgumentParser, numkey::Integer, value::Any) → parser
    set_value!(parser::ArgumentParser, argname::AbstractString, value::Any) → parser

Set/update value of argument, validating it, as specified by `numkey` or `argname`, in parser.

# Throws
- `Exception`: depending on the value of `throw_on_exception` , if the argument not 
    found, the function will either throw imediately, or return `e <: Exception` to be 
    processed downstream.

Function `set_value!` is exported.
"""
function set_value!(parser::ArgumentParser, numkey::Integer, value::Any)
    thr_on_exc = throw_on_exception(parser)
    !haskey(parser.kv_store, numkey) && return _error(thr_on_exc, "Key not found in store.")
    vals::ArgumentValues = parser.kv_store[numkey]
    vld = vals.validator
    value = convert(vals.type, value)
    (ok, value) = validate(value, vld)
    ok || return _error(thr_on_exc, "$value is not a valid value for arg $(canonicalname(vals.args))") 
    parser.kv_store[numkey] = ArgumentValues(vals.args, value, vals.type, vals.positional, vals.description, vals.validator)
    return parser
end

function set_value!(parser::ArgumentParser, argname::AbstractString, value::Any)
    thr_on_exc =throw_on_exception(parser)
    strkey = arg2strkey(argname)
    !haskey(parser.arg_store, strkey) && return _error(thr_on_exc, "Argument not found in store.")
    numkey = parser.arg_store[strkey]
    return set_value!(parser, numkey, value)
end

"""
    _error(throw_on_exception, msg::AbstractString; excp=ArgumentError) → ::Exception

Depending on value of `throw_on_exception`, throw immediately, or return `Exception` to be 
processed downstream.

Function `_error` is internal.
"""
_error(thr_on_exc, msg; excp=ArgumentError) = thr_on_exc ? throw(excp(msg)) : excp(msg) 

# Type conversion helper methods.
_parse(x, y) = parse(x, y)
_parse(::Type{String},   x::Number)  = x
_parse(::Type{String},   x::String)  = x
_parse(::Type{Bool},     x::Bool)    = x
_parse(::Type{Number},   x::Number)  = x
_parse(::Type{String},   x::Bool)    = x ? "true" : "false"
