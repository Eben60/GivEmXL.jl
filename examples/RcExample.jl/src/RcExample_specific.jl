
gr()

DATATABLENAME = "data"

function timerange(df0, t1, t2)
    df = subset(df0, :ts => x -> (x.>t1).&(x.<t2))
    ts = Float64.(df[!, :ts]);
    ys = Float64.(df[!, :ys]);
    return (; ts, ys)
end

function nl_lsq_fit(model, u0, xdata, ydata, p)
    data = (xdata, ydata, p)

    function lossfn!(du, u, data)
        (xs, ys, p) = data   
        du .= model.(xs, Ref(u), Ref(p)) .- ys
        return nothing
    end

    prob = NonlinearLeastSquaresProblem(
        NonlinearFunction(lossfn!, resid_prototype = similar(ydata)), u0, data)
    sol = solve(prob)
    u = sol.u
    fit = model.(xdata, Ref(u), Ref(p))
    return (;sol, fit)
end

function expmodel(x, u, t₀=0)
    # y0 = u[1]
    a = u[1]
    τ = u[2]
    return a * exp(-(x-t₀)/τ) # + y0 
end

function proc_dataspan(df, t_start, t_stop)
    t_start = t_start |> ustrip
    t_stop = t_stop |> ustrip
    (; ts, ys) = timerange(df, t_start, t_stop);
    aᵢ = (ys[1])
    τᵢ = (t_stop - t_start) / 2
    t₀ᵢ = t_start
    (;sol, fit) = nl_lsq_fit(expmodel, [aᵢ, τᵢ], ts, ys, t₀ᵢ)
    a, τ = sol.u
    pl = plot(ts, [ys, fit]; label = ["experiment" "fit"])
    return (;a, τ, sol, fit, pl)
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

function procwhole(xlfile, datafiles, paramsets)
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
    (;a, τ, sol, pl) = rslt
    finalize_plot!(pl, pm_subset)
    rs = (;subset=i, no, a, τ, sol, pl, plot_annotation)
    a *= Vunit
    τ *= timeunit
    c = (τ / R) 
    c = c |> Cunit 
    d = calc_thickness(c, ϵ, area)
    df_row = (;no, a, τ, c, d, R, ϵ, comment, t_start, t_stop)
    return (;rs, df_row)
end
