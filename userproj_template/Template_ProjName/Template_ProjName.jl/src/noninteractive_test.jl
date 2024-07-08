using Pkg
basedir = path=(joinpath(@__DIR__, "../") |> normpath)
Pkg.activate(basedir)

"""
such a script can be used to develop your package first without the cli dialogs
"""
module TestRc

using Template_ProjName
using GivEmExel 

fl_no = 1

sourcefolder = normpath(joinpath(@__DIR__, "..", "data"))

testfiles = ["Template_ProjNameData.xlsx",
    "MissingData.xlsx",
    "BrokenData.xlsx",
    ]

fl = joinpath(sourcefolder, testfiles[fl_no])

plotformat="png"
throwonerr=true

cliargs = (;plotformat, throwonerr)

(;df_setup, df_exp) = read_xl_paramtables(fl; paramtables=(;setup="params_setup", exper="params_experiment"));
paramsets = exper_paramsets(cliargs, df_exp, df_setup)
# (;plots, dataframes, data) = preproc(fl, nothing, paramsets)
rslt = proc_n_save(preproc, procsubset, postproc; paramsets, xlfile=fl);

end

rslt = TestRc.rslt;