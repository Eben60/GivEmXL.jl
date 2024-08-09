using PrecompileTools: @setup_workload, @compile_workload 

@setup_workload begin
    # put your workload file into the data folder
    testfiles = ["Table1.csv",
        ]
    sourcefolder = normpath(joinpath(@__DIR__, "..", "data"))
    cliargs = (;throwonerr=false, start=5, lastrow=50)
    d = Base.Filesystem.tempdir()

    @compile_workload begin
        include("init_cli_options.jl")
        for fnm in testfiles
            f = joinpath(sourcefolder, fnm)
            fl = joinpath(d, fnm)
            "put your workload here"
            # cp(f, fl; force=true)
            # (;df_setup, df_exp) = read_xl_paramtables(fl; paramtables=(;setup="params_setup", exper="params_experiment"));
            # paramsets = exper_paramsets(cliargs, df_exp, df_setup)
            # rslt = proc_n_save(preproc, procsubset, postproc; paramsets, xlfile=fl)
        end
    end
end