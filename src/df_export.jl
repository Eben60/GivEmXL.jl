function anyfy_col!(df, cname) 
    df[!, cname] = Vector{Any}(df[!, cname])
    return nothing
end

function prepare_xl(df0)
    df = copy(df0)
    headers = String[]
    for nm in names(df)
        (;colheader, v) = sep_unit(df[!, nm])
        # (eltype(df[!, nm]) <: AbstractString) || 
        anyfy_col!(df, nm)
        push!(headers, colheader)
        colheader == "" || (df[!, nm] = v)
    end
    pushfirst!(df, headers)
    return df
end

function sep_unit(v)
    (eltype(v) <: Quantity) || return (;colheader = "", v)
    colheader = v |> eltype |> unit |> string
    v = v .|> ustrip |> Vector{Any}
    (;colheader, v)
end