module SavingResults

using ..GivEmExel 
using GivEmExel: isplot, save_plot

using Unitful, DataFrames, XLSX 

export proc_n_save

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

                comment = get(e, :comment, "no further info")
                back_trace = get(e, :back_trace, nothing)


                println(io, "row = $row: $comment")
                println(io, "Errored: $exceptn")
                println(io, "-------- backtrace --------")
                if back_trace isa Vector
                    for sf in back_trace
                        println(io, sf)
                    end
                end
                println(io, "_"^80, "\n")
                back_trace
            end
        end
    end
    return errored
end

getplots(itr) = [k => v for (k, v) in pairs(itr) if isplot(v)]

function saveplots(rs, rslt_dir; plotformat = "png", kwargs...)
    plotformat = lowercase(string(plotformat))
    plotformat == "none" && return nothing
    
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
        fname = replace(fname, " " => "_")
        fl = joinpath(rslt_dir, fname)
        save_plot(pl, fl)
    end
    return nothing
end

function proc_data(xlfile, datafiles, paramsets, procwhole_fn, procsubset_fn; throwonerr=false)
    subsets_results = []
    errors = []
    overview = (;)
    try
        overview = procwhole_fn(xlfile, datafiles, paramsets)
        for (i, pm_subset) in pairs(paramsets)
            try
                push!(subsets_results, procsubset_fn(i, pm_subset, overview, xlfile, datafiles, paramsets))
            catch exceptn
                back_trace = stacktrace(catch_backtrace())
                comment = get(pm_subset, :comment, "")
                push!(errors, (;row=i, comment, exceptn, back_trace))
                throwonerr && rethrow(exceptn)
            end    
        end     
    catch exceptn
        back_trace = stacktrace(catch_backtrace())
        push!(errors,(;row=-1, comment="error opening of processing data file", exceptn, back_trace))
        throwonerr && rethrow(exceptn)
    end
    return (; overview, subsets_results, errors)
end

function combine2df(subsets_results)
    rows = []
    for sr in subsets_results
        r = get(sr, :df_row, nothing)
        isnothing(r) || push!(rows, r)
    end
    isempty(rows) && return nothing
    return DataFrame(rows)
end

function write_xl_tables(fl, nt_dfs; overwrite=true)
    ps = [string(k)=>v for (k, v) in pairs(nt_dfs)]
    XLSX.writetable(fl, ps; overwrite)
end

function save_dfs(overview, subsets_results, outf)
    subsets_df = combine2df(subsets_results)
    overview_dfs = get(overview, :dataframes, nothing)
    isnothing(overview_dfs) && (overview_dfs=(;))
    dfs = (;)
    if !isnothing(subsets_df) 
        subsets_df = prepare_xl(subsets_df)
        dfs = merge(overview_dfs, (;SubsetsRslt=subsets_df))
    end

    isempty(dfs) || write_xl_tables(outf, dfs)
    return dfs
end

function save_plots(overview, subsets_results, rslt_dir, paramsets)
    plots = get(overview, :plots, nothing)
    isnothing(plots) && (plots=(;))
    ps1 = paramsets[1]
    ntkwargs = haskey(ps1, :plotformat) ? (; plotformat = ps1.plotformat) : (;)
    if !isempty(plots)
        plots = merge(plots, (;subset=0))
        saveplots(plots, rslt_dir; ntkwargs...)
    end
    for subs in subsets_results
        saveplots(subs.rs, rslt_dir; ntkwargs...);
    end
    return nothing
end

function save_results(results, xlfile, paramsets)
    (; overview, subsets_results, errors) = results
    (;fname, f_src, src_dir, rslt_dir, outf, errf) = out_paths(xlfile)
    dfs = save_dfs(overview, subsets_results, outf)
    save_plots(overview, subsets_results, rslt_dir, paramsets)
    write_errors(errf, errors)
    return (;dfs)
end

function proc_n_save(procwhole_fn, procsubset_fn;
        xlfile,
        datafiles=nothing, 
        paramsets = [(;)],
        # paramtables=(;setup="params_setup", exper="params_experiment"),
        )
    throwonerr = get(paramsets[1], :throwonerr, false)
    # (;df_setup, df_exp) = read_xl_paramtables(xlfile; paramtables)
    # paramsets = exper_paramsets(paramsets, df_exp, df_setup);
    results = proc_data(xlfile, datafiles, paramsets, procwhole_fn, procsubset_fn; throwonerr)
    (; overview, subsets_results, errors) = results
    (;dfs) = save_results(results, xlfile, paramsets)
    return (; overview, subsets_results, errors, dfs) 
end

end # module SavingResults