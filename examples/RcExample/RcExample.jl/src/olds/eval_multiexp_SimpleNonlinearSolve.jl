using Unitful, DataFrames, XLSX, Plots
using GivEmExel, GivEmExel.SavingResults
using RcExample

# plotlyjs()

f = "data/MissingData.xlsx";

f = "data/RcExampleData.xlsx"
# f = "data/BrokenData.xlsx";
fl = joinpath(@__DIR__, "..", f);




(;df_setup, df_exp) = read_xl_paramtables(fl);
# (;nt) = merge_params(df_exp, df_setup, 1);

pst = exper_paramsets((;), df_exp, df_setup);
(;fname, f_src, src_dir, rslt_dir, outf, errf) = out_paths(fl)

(;results, errors, results_df, overview) = _proc_data(fl, nothing, pst) # ; throwonerr=false);

if !isempty(results_df)
    df2save = prepare_xl(results_df);
    XLSX.writetable(outf, "Results" => df2save; overwrite=true)
end

errored = write_errors(errf, errors)

# pl1 = results[1].pl
# pl2 = results[2].pl
# pl3 = results[3].pl;

# pls = (;pl1, pl2, pl3, a=3)
# getplots(pls)
saveplots.(results, Ref(rslt_dir); (pst[1]...));
saveplots(overview, rslt_dir; (pst[1]...));