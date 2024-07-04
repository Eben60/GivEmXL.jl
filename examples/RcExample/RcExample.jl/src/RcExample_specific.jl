
gr()

DATATABLENAME = "data"

function timerange(df0, t1, t2)
    df = subset(df0, :ts => x -> (x.>t1).&(x.<t2))
    ts = Float64.(df[!, :ts]);
    ys = Float64.(df[!, :ys]);
    return (; ts, ys)
end

function easyexpfit(ts, ys, t₀ᵢ)
    ts = ts .- t₀ᵢ
    fit = fitexp(ts, ys)
    return (; a=fit.a, τ=fit.b, c=fit.c, Rpears=fit.R, ypred=fit.ypred)
end

function proc_dataspan(df, t_start, t_stop)
    t_start = t_start |> ustrip
    t_stop = t_stop |> ustrip
    (; ts, ys) = timerange(df, t_start, t_stop);
    (; a, τ, c, Rpears, ypred) = easyexpfit(ts, ys, t_start)
    pl = plot(ts, [ys, ypred]; label = ["experiment" "fit"])
    return (;a, τ, c, Rpears,  pl)
end

function readdata(fl)
    df = DataFrame(XLSX.readtable(fl, DATATABLENAME; infer_eltypes=true))
    ts = df[!, :ts];
    ys = df[!, :ys];
    pl0 = plot(ts, ys)
    return (; df, pl0)
end

calc_thickness(C, ϵ, area) = ϵ * ϵ0 * area / C |> u"µm"

function finalize_plot!(pl, params)
    (; Vunit, timeunit, plot_annotation) = params
    sz = (800, 600)
    xunit = timeunit |> string
    yunit = Vunit |> string
    pl = plot!(pl; 
        size=sz, 
        xlabel = "time [$xunit]", 
        ylabel = "Voltage [$yunit]", 
        title = "$plot_annotation",
        )
    return pl
end

function preproc(xlfile, datafiles, paramsets)
    (; df, pl0) = readdata(xlfile)
    plots = (; pl0, plot_annotation="overview plot")
    # df1 = DataFrame([(; a=1, b=2)])
    # df2 = DataFrame([(; c=3, d=4)])
    # dataframes = (; df1, df2)
    dataframes=nothing
    data = (; df)
    return (;plots, dataframes, data)
end

function procsubset(i, pm_subset, overview, args...) 
    (; area, Vunit, timeunit, Cunit, R, ϵ, no, plot_annotation, comment, t_start, t_stop) = pm_subset
    df = overview.data.df
    rslt = proc_dataspan(df, t_start, t_stop)
    (;a, τ, c, Rpears, pl) = rslt
    finalize_plot!(pl, pm_subset)
    rs = (;subset=i, no, a, τ, c, Rpears, pl, plot_annotation)
    a *= Vunit
    τ *= timeunit
    c = (τ / R) 
    c = c |> Cunit 
    d = calc_thickness(c, ϵ, area)
    df_row = (;no, a, τ, c, Rpears, d, R, ϵ, comment, t_start, t_stop)
    return (;rs, df_row)
end

function stringify!(df)
    for n in names(df)
        df[!, n] = string.(df[!, n])
    end
    return nothing
end

function postproc(xlfile, datafiles, paramsets, overview, subsets_results)
    df_summary = describe(combine2df(subsets_results))
    stringify!(df_summary) 
    return (; dataframes=(; summary=df_summary))
end