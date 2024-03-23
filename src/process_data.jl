# function process_data(f_src)
#     read_xl_paramtables(f_src)
# end

function remove_comments(df)
    col1 = df[!, 1]
    iscomment = isa.(col1, AbstractString) .&& startswith.(col1, r"\"?#")
    return df[.!iscomment, :]
end

read_xl_removecomments(f_src, tablename) = DataFrame(XLSX.readtable(f_src, tablename; infer_eltypes=true)) |> remove_comments

function read_xl_paramtables(f_src; paramtables=(;setup="params_setup", exper="params_experiment"))
    (; setup, exper) = paramtables
    df_setup = isnothing(setup) ? nothing : read_xl_removecomments(f_src, setup)
    df_exp = isnothing(exper) ? nothing : read_xl_removecomments(f_src, exper)
    return (;df_setup, df_exp)
end

function s2unit(s)
    ismissing(s) && return s
    s1 = "u$s"
    x = eval(Meta.parse(s1))
    return x
end

read_units(df_setup) = NamedTuple((k, s2unit(v)) for (k, v) in pairs(df_setup[2, :]))

# keys_skipmissing(nt) = [k for (k, v) in pairs(nt) if !ismissing(v)]

nt_skipmissing(nt) = NamedTuple((k, v) for (k, v) in pairs(nt) if !ismissing(v))

function nt2unitful(nt, ntunits)
    ntunits = nt_skipmissing(ntunits)
    ntu = NamedTuple((k, v*ntunits[k]) for (k, v) in pairs(nt) if k in keys(ntunits))
    ntu = merge(nt, ntu)
    return merge(ntunits, ntu)
end

function merge_params(df_exp, df_setup, row)
    nt_exp = NamedTuple(df_exp[row, :]) |> nt_skipmissing
    nt_setup = NamedTuple(df_setup[1, :]) |> nt_skipmissing
    nt_units = read_units(df_setup)
    nt_unitless = merge(nt_setup, nt_exp)
    nt = nt2unitful(nt_unitless, nt_units)

    return (;nt,nt_exp, nt_setup, nt_unitless)
end

mergent(args) = merge((;), [NamedTuple(a) for a in args]...)
mergent(args...) = mergent([args...])