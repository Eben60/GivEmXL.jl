using Pkg
basedir = path=(joinpath(@__DIR__, "../") |> normpath)
Pkg.activate(basedir)

"""
such a script can be used to develop your package first without the cli dialogs
"""
module TestNonIntr

using Template_ProjName
using GivEmXL 

sourcefolder = normpath(joinpath(@__DIR__, "..", "data"))

fl = joinpath(sourcefolder, "Template_ProjNameData.xlsx")

plotformat="png"
throwonerr=true

cliargs = (;plotformat, throwonerr)

(;df_setup, df_exp) = read_xl_paramtables(fl; paramtables=(;setup="params_setup", exper="params_experiment"));
paramsets = exper_paramsets(cliargs, df_exp, df_setup)
rslt = proc_n_save(preproc, procsubset, postproc; paramsets, xlfile=fl);

end

rslt = TestNonIntr.rslt;