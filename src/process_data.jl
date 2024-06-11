using Unitful: lookup_units

"""
    s2unit(str::AbstractString) → ::Quantity

Strips all kinds of quotation marks and parses a string into `Quantity`. 
See also `Unitful.uparse`

# Throws

- On conversion error

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

Comment is any row starting with `#` - these rows will be omitted.

Function `remove_comments` is internal.
"""
function remove_comments(df)
    col1 = df[!, 1]
    iscomment = isa.(col1, AbstractString) .&& startswith.(col1, r"\"?#")
    return df[.!iscomment, :]
end

read_xl_removecomments(f_src, tablename) = DataFrame(XLSX.readtable(f_src, tablename; infer_eltypes=true)) |> remove_comments

"""
    read_xl_paramtables(f_src; paramtables=(;setup="params_setup", exper="params_experiment")) 
        → (; df_setup::Union{Nothing, DataFrame}, df_exp::Union{Nothing, DataFrame})

Reads the two tables (if not `nothing`) from an XLSX file into corresponding DataFrames and strips comments, if any. 
Comment is any row starting with `#` 

# Argument
- `f_src::String`: File path

# Keyword argument
- `paramtables=(;setup::Union{Nothing, String}="params_setup", exper::Union{Nothing, String}="params_experiment")`

# Returned NamedTuple
- `(;df_setup::Union{Nothing, DataFrame}, df_exp::Union{Nothing, DataFrame}`

Function `read_xl_paramtables` is exported.
"""
function read_xl_paramtables(f_src; paramtables=(;setup="params_setup", exper="params_experiment"))
    (; setup, exper) = paramtables
    df_setup = isnothing(setup) ? nothing : read_xl_removecomments(f_src, setup)
    df_exp = isnothing(exper) ? nothing : read_xl_removecomments(f_src, exper)
    return (;df_setup, df_exp)
end

"""
    read_units(df_setup::DataFrame) → NamedTuple
    read_units(d::Nothing) = (;)

Function `read_units` is internal.

# Examples
```julia-repl
julia> GivEmExel.read_units(df_setup)
(area = cm², Vunit = mV, timeunit = s, Cunit = nF, R = GΩ, t_start = s, t_stop = s, ϵ = missing)

julia> typeof(ans.timeunit)
Unitful.FreeUnits{(s,), 𝐓, nothing}
```
"""
read_units(df_setup) = NamedTuple((k, s2unit(v)) for (k, v) in pairs(df_setup[2, :]))
read_units(d::Nothing) = (;)

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
    merge_params(df_exp::Union{Nothing, DataFrame}, df_setup::Union{Nothing, DataFrame}, row::Integer) → (;nt, nt_exp, nt_setup, nt_unitless)

Merges default parameters and units from df_setup with the parameter in the given row of df_exp, and returns them as NamedTuple of NamedTuples. 
Actually only the `nt` field of the returned value is used.

Function `merge_params` is public.

# Examples
```julia-repl
julia> m = GivEmExel.merge_params(df_exp, df_setup, 1);
julia> m.nt
(area = 0.5 cm², Vunit = mV, timeunit = s, Cunit = nF, R = 5 GΩ, t_start = 1 s, t_stop = 4 s, ϵ = 3.7, no = 1, plot_annotation = "first discharge", comment = "first discharge – 1")
```
"""
function merge_params(df_exp, df_setup, row)
    nt_setup = isnothing(df_setup) ? (;) : (NamedTuple(df_setup[1, :]) |> nt_skipmissing)
    nt_exp = isnothing(df_exp) ? (;) : (NamedTuple(df_exp[row, :]) |> nt_skipmissing)
    nt_units = read_units(df_setup)
    nt_unitless = merge(nt_setup, nt_exp)
    nt = nt2unitful(nt_unitless, nt_units)

    return (;nt, nt_exp, nt_setup, nt_unitless)
end

"""
    mergent(args::Array) → ::NamedTuple
    mergent(args...) → ::NamedTuple

Merges multiple `NamedTuple`s, or arguments convertible to `NamedTuple`s (e.g. `Dict`, `pairs`).

Function `mergent` is internal.
"""
mergent(args) = merge((;), [NamedTuple(a) for a in args]...)
mergent(args...) = mergent([args...])
