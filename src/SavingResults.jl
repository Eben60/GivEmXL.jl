module SavingResults

using GivEmExel
import GivEmExel: prepare_xl, out_paths, write_errors, saveplots


using Unitful, DataFrames, XLSX, Plots

export prepare_xl, out_paths, write_errors, saveplots

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

function out_paths(f_src)
    ! isfile(f_src) && error("file \"$f_src\" do not exist")
    src_dir, fname = splitdir(f_src)
    fname, _ = splitext(fname)
    rslt_dir = joinpath(src_dir, "$(fname)_rslt")
    mkpath(rslt_dir)
    
    outf_name = "$(fname)_rslt.xlsx"
    errf_name = "$(fname)_err.txt"
    outf = joinpath(rslt_dir, outf_name)
    errf = joinpath(rslt_dir, errf_name)

    rm(errf; force=true)

    return (;fname, f_src, src_dir, rslt_dir, outf, errf)
end

function write_errors(errf, errors)
    errored = !isempty(errors)
    if errored
        open(errf, "w") do io
            for e in errors
                e = NamedTuple(e)
                (;row, exceptn) = e
                
                if haskey(e, :comment) 
                    comment = e.comment
                else
                    comment = "no further info"
                end

                println(io, "row = $row: $comment")
                println(io, "Errored: $exceptn \n")
            end
        end
    end
    return errored
end

getplots(itr) = [k => v for (k, v) in pairs(itr) if isplot(v)]

isplot(::Any) = false
isplot(::P ) where P <: Plots.Plot = true

_saveplot(pl::P, fl) where P <: Plots.Plot = savefig(pl, fl)

function saveplots(rs, rslt_dir; plotformat = "png", kwargs...)
    # rs = Dict(pairs(rs))
    subset = get(rs, :subset, 0)
    no = get(rs, :no, subset)
    plot_annotation = get(rs, :plot_annotation, "")
    allplots = getplots(rs)
    singleplot = length(allplots) == 1
    for (k, v) in allplots
        pl = v
        prefix = subset==no ? "fig$no" : "fig$subset-$no"
        singleplot || (prefix *= "_$(k)_")
        fname = "$(prefix)_$plot_annotation.$plotformat"
        fl = joinpath(rslt_dir, fname)
        _saveplot(pl, fl)
    end
    return nothing
end

end