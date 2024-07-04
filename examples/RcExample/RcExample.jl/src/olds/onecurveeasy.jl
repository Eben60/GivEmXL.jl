using Pkg
basedir = path=(joinpath(@__DIR__, "../") |> normpath)
Pkg.activate(basedir)


using RcExample
using GivEmExel 
using DataFrames, XLSX, Plots
using EasyFit: fitexp


sourcefolder = normpath(joinpath(@__DIR__, "..", "data"))

fl = joinpath(sourcefolder, "RcExample-1curve.xlsx")


(;df_setup, df_exp) = read_xl_paramtables(fl; paramtables=(;setup="params_setup", exper="params_experiment"));
paramsets = exper_paramsets((;), df_exp, df_setup)

(; t_start, t_stop) = paramsets[1]

# (t_start = 1 s, t_stop = 4 s)

i1 = 102
i2 = 402

xy = DataFrame(XLSX.readtable(fl, "data"; infer_eltypes=true));
ts = (xy.ts[i1:i2] .- 1) .|> Float64 
ys = xy.ys[i1:i2] .|> Float64
fit = fitexp(ts, ys)

plot(ts, [ys, fit.ypred])

;