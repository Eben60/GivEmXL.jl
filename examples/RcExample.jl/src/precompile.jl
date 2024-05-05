using PrecompileTools: @setup_workload, @compile_workload 

# testfiles = ["data/RcExampleData.xlsx",
# "data/MissingData.xlsx",
# "data/BrokenData.xlsx",
# ]



@setup_workload begin
    testfiles = ["MissingData.xlsx",
        ]
    sourcefolder = normpath(joinpath(@__DIR__, "..", "data"))
    cliargs = (;plotformat="none", throwonerr=false)
    d = Base.Filesystem.tempdir()

    @compile_workload begin
        for fnm in testfiles
            # fnm = splitpath(f)[end]
            f = joinpath(sourcefolder, fnm)
            fl = joinpath(d, fnm)
            cp(f, fl; force=true)
            (;df_setup, df_exp) = read_xl_paramtables(fl; paramtables=(;setup="params_setup", exper="params_experiment"));
            paramsets = exper_paramsets(cliargs, df_exp, df_setup)
            rslt = proc_n_save(procwhole, procsubset; paramsets, xlfile=fl);
        end
    end
end