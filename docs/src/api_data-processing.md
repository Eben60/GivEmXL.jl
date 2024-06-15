## API data processing

The processing is performed in three steps: preprocessing, processing of each subset in a loop, and postprocessing. Each step can be however skipped. You have to provide the corresponding functions for each of the steps, except skipped ones (you have the free choice in respect to their names). Results of each step are merged with the results of the previous one and passed to the following one. The processing data and saving results is performed by the function [`proc_n_save`](@ref GivEmExel.proc_n_save), which calls the functions [`proc_data`](@ref GivEmExel.proc_data) and [`save_results`](@ref GivEmExel.save_results), respectively. The results are saved into a sub-directory of the excel file folder, and contain plots, the multi-table results file in XLSX format, and maybe a text file with errors information.

### Parameter passed to data processing functions
- `xlfile::String`: path to the exel file (in general case, `Union{Nothing, String}`)
- `datafiles::Nothing`: we put our data into the same exel file (in general case, `Union{Nothing, String, Vector{String}}`)
- `paramsets::Vector{NamedTuple}`: In our case, there will be 3 NamedTuples, one for each row of the table `params_experiment`. Each NamedTuple will contain the data as defined in the corresponding row as well a (repeating) data from the user input (here only `plotformat` defined) and the table table `params_experiment`, e.g. 
```
julia> paramsets[1]
(plotformat = "png", throwonerr = true, area = 0.5 cm², Vunit = mV, timeunit = s, Cunit = nF, R = 5 GΩ, t_start = 1 s, t_stop = 4 s, ϵ = 3.7, no = 1, plot_annotation = "first discharge", comment = "first discharge – 1")
```

### Preprocessing

The preprocessing function must take three arguments discussed above, like `fn_preproc(xlfile, datafiles, paramsets)`, and expected to return a NamedTuple as following `(;plots, :dataframes, :data)`:
- `plots::Union{Nothing, NamedTuple{(:plot_annotation, plots...)}}`: e.g. `(;plot_annotation="overview", ov1=pl1, ov2=pl2)` - here `pl1` and `pl2` are plot objects. The annotation will be a part of the file name(s), and if there are multiple plots, their names (e.g. `pl1`) will be compounded into the file name, too. Each plot will be eventually saved to a separate file.
- `dataframes::Union{Nothing, NamedTuple{(dataframes...)}}`: e.g. `(; overview_table=df1)`. Each dataframe will be saved into a correspondingly named table of the results file in XLSX format.
- `data::Any`: The data to be passed to the following processing steps.

### Subset processing

The subset processing function must take arguments like following: `fn_subset(i, pm_subset, overview, xlfile, datafiles, paramsets)`:
- `i`: Subset number.
- `pm_subset=paramsets[i]`: For `paramsets`, see above (and yes, I know, it's kind of redundant).
- `overview::NamedTuple{(:plots, :dataframes, :data)}`: NamedTuple as returned by the preprocessing function.
- for the rest of the arguments, see above.

It is expected to return a `NamedTuple` as following `(;rs, df_row)`:
- `rs::NamedTuple{(:subset, :plot_annotation, plots..., more results... )}`: Where `subset=i`, and `plot_annotation` and `plots...` have the same meaning as for preprocessing.
- `df_row::NamedTuple`: The subset results to be afterwards concatenated into a `DataFrame` and saved as a table of an excel file.

### Postprocessing

The postprocessing function must take arguments like following: `fn_postproc(xlfile, datafiles, paramsets, overview, subsets_results)`:
- `subsets_results::Vector{NamedTuple{(:rs, :df_row)}}`: Concatenation of subset processing results.
- for all other parameters, see above.

It is expected to return a `NamedTuple` as following `(;plots, :dataframes)` - see **Preprocessing** above for details.

### Plot objects

If your data processing functions return `Plots` or `Makie` objects, that is supported out of the box. If you use some other package, or maybe want to save some other objects instead of or additionally to the plots, you have to define your own methods for in the following way (see also package extension files in the `GivEmExel` folder `ext/` as an example):

```
import GivEmExel: isplot, save_plot
using Foo

isplot(::Foo.foo_plot) = true
save_plot(pl::::Foo.foo_plot, fl) = Foo.saveplot(pl, fl)
```