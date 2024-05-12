using Unitful: lookup_units

"""
    s2unit(str::AbstractString) → ::Quantity

Strips all kinds of quotation marks and parses a string into `Quantity`. 
See also `Unitful.uparse`

Function `s2unit` is internal.
"""
function s2unit(str; unit_context=Unitful)
    # Unitful.uparse() breaks precompilation
    # https://github.com/PainterQubits/Unitful.jl/issues/649
    # https://github.com/PainterQubits/Unitful.jl/pull/655 
    ismissing(str) && return str

    ex = nothing
    qmarks = ['"', '\'', '«', '»', '‘', '’', '“', '”', '„', '‟', ]
    try
        str = strip(str, qmarks)
        ex = Meta.parse(str)
        isa(ex, Symbol) && return lookup_units(unit_context, ex)
        isa(ex, Number) && return lookup_units(unit_context, ex)
        ex_processed = lookup_units(unit_context, ex)
        return JuliaInterpreter.finish_and_return!(JuliaInterpreter.Frame(Unitful, ex_processed))
    catch e
        println("error trying to convert $str")
        rethrow(e)
    end
end

"""
    remove_comments(df::DataFrame) → ::DataFrame

Function `remove_comments` is internal.
"""
function remove_comments(df)
    col1 = df[!, 1]
    iscomment = isa.(col1, AbstractString) .&& startswith.(col1, r"\"?#")
    return df[.!iscomment, :]
end

read_xl_removecomments(f_src, tablename) = DataFrame(XLSX.readtable(f_src, tablename; infer_eltypes=true)) |> remove_comments

"""
    read_xl_paramtables(f_src; paramtables=(;setup::Union{Nothing, String}="params_setup", exper::Union{Nothing, String}="params_experiment")) → (; df_setup::Union{Nothing, DataFrame}, df_exp::Union{Nothing, DataFrame})

Reads the two tables (if not `nothing`) into corresponding DataFrames and strips comments, if any. Comment is any row starting with `#` 

Function `read_xl_paramtables` is public/exported?.
"""
function read_xl_paramtables(f_src; paramtables=(;setup="params_setup", exper="params_experiment"))
    (; setup, exper) = paramtables
    df_setup = isnothing(setup) ? nothing : read_xl_removecomments(f_src, setup)
    df_exp = isnothing(exper) ? nothing : read_xl_removecomments(f_src, exper)
    return (;df_setup, df_exp)
end

read_units(df_setup) = NamedTuple((k, s2unit(v)) for (k, v) in pairs(df_setup[2, :]))
read_units(d::Nothing) = (;)

# keys_skipmissing(nt) = [k for (k, v) in pairs(nt) if !ismissing(v)]

nt_skipmissing(nt) = NamedTuple((k, v) for (k, v) in pairs(nt) if !ismissing(v))

"""
    nt2unitful(nt, ntunits) → NamedTuple

Applies units from `ntunits` to the values from `nt`

Function `nt2unitful` is internal.

# Examples
```julia-repl
julia> nt2unitful((; a=2.0, b=3), (;a=u"cm/s"))
(a = 2.0 cm s⁻¹, b = 3)
```
"""
function nt2unitful(nt, ntunits)
    ntunits = nt_skipmissing(ntunits)
    ntu = NamedTuple((k, v*ntunits[k]) for (k, v) in pairs(nt) if k in keys(ntunits))
    ntu = merge(nt, ntu)
    return merge(ntunits, ntu)
end


"""
    merge_params(df_setup::Union{Nothing, DataFrame}, df_exp::Union{Nothing, DataFrame}, row::Integer) → (;nt, nt_exp, nt_setup, nt_unitless)

Merges default parameters and units from df_setup with the parameter in the given row of df_exp, and returns them as NamedTuple

Function `merge_params` is public/exported?.
"""
function merge_params(df_exp, df_setup, row)
    nt_setup = isnothing(df_setup) ? (;) : (NamedTuple(df_setup[1, :]) |> nt_skipmissing)
    nt_exp = isnothing(df_exp) ? (;) : (NamedTuple(df_exp[row, :]) |> nt_skipmissing)
    nt_units = read_units(df_setup)
    nt_unitless = merge(nt_setup, nt_exp)
    nt = nt2unitful(nt_unitless, nt_units)

    return (;nt, nt_exp, nt_setup, nt_unitless)
end

mergent(args) = merge((;), [NamedTuple(a) for a in args]...)
mergent(args...) = mergent([args...])
