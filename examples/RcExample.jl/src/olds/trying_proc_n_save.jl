# using Unitful, DataFrames, XLSX, Plots
using GivEmExel.SavingResults
using GivEmExel
using RcExample

using GivEmExel.SavingResults: proc_data


projbase = dirname(Base.active_project())
f = "MissingData.xlsx";

f = "RcExampleData.xlsx"
# f = "BrokenData.xlsx";
xlfile = joinpath(projbase, "data", f);

# rslt = proc_n_save(fl, nothing, procwhole, procsubset; [paramsets=(;plotformat="svg", throwonerr=true)]);
# rslt = proc_n_save(procwhole, procsubset; xlfile=fl, paramsets=[(;plotformat="svg", throwonerr=true)]);

(;df_setup, df_exp) = read_xl_paramtables(xlfile; paramtables=(;setup="params_setup", exper="params_experiment"));
cliargs = (;)
# cliargs = (;plotformat="none", throwonerr=false)
paramsets = exper_paramsets(cliargs, df_exp, df_setup)

# results = proc_data(xlfile, nothing, paramsets, procwhole, nothing;)

# rslt = proc_n_save(procwhole, procsubset; paramsets, xlfile);
; #, paramsets=[(;plotformat="svg", throwonerr=true)]);

function procwhsubset(i, pm_subset, overview, xlfile, datafiles, paramsets)
    overview = procwhole(xlfile, datafiles, paramsets)
    return procsubset(i, pm_subset, overview)
end

rslt = proc_n_save(procwhole, nothing; paramsets, xlfile);

rslt = proc_n_save(nothing, procwhsubset; paramsets, xlfile);