[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Lifecycle:Maturing](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://eben60.github.io/GivEmExel.jl/) 
[![Build Status](https://github.com/Eben60/GivEmExel.jl/workflows/CI/badge.svg)](https://github.com/Eben60/GivEmExel.jl/actions?query=workflow%3ACI) 
[![Coverage](https://codecov.io/gh/Eben60/GivEmExel.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Eben60/GivEmExel.jl) 
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

# GivEmExel - build your poor man's interactive app

## Package purpose

Let's assume you are the only `Julia`  user/programmer among your colleagues. Maybe the only one who does programming at all – all others mostly use Microsoft® Excel® [^smallprint] for their computations, or else some specialized (GUI) software. 

[^smallprint]:

    throughout the text, "excel file" (no capitalisation) and "XLSX file" will be used interchangeably and denote files in the XLSX format, which can be produced and read by MS Excel as well as other software, e.g. LibreOffice.

Now, you have developed a script for some computation or data analysis which they would be glad to use – but asking them to accept your programmers workflow would be asking too much. Building a full GUI for your script to be used by merely a couple of users would be an time-consuming overkill. Enter `GivEmExel`: with this package you are able to produce "somewhat interactive" packages for use by your non-programming colleagues.

## Another package purpose

My motivation was actually initially different. I used a Julia script to process experimental data, and for each experiment there were about a dozen or so of experiment-specific parameter plus a dozen of parameters specific for each separate measurement within the experiment. For each measurement, my script produced a further dozen of numbers. Using MS Excel proved to be a practical way to manage the parameter and results and to share them with the colleagues. Then with a bit of additional programming I could also share the script itself and let them process their data on their own: That happened to be a nice side effect.

## Toy example - evaluation of capacitor discharge curves

See the source under [`examples/RcExample`](https://github.com/Eben60/GivEmExel.jl/tree/main/examples/RcExample)

### From the user's point of view

Your colleague receives from you
* Instructions for `Julia` installation on their computer
* An excel template file containing one or two tables
* A folder (or zip file) to be copied/extracted somewhere onto their computer. The folder contains two batch files (`.bat` on Windows an `.sh` on unixes), and some other folder enclosed. One of the batch files is `instantiate.bat` to be run once.

Let's look into the contents of the Excel files. The first of them is called `param_setup` and contains the default values (here for `area` and `ϵ`) and the units like following:

area|Vunit|timeunit|Cunit|R|t_start|t_stop|ϵ
---|---|---|---|---|---|---|---
0.5|||||||3.7
"cm^2"|"mV"|"s"|"nF"|"GΩ"|"s"|"s"|

The second one is `params_experiment` with the following contents:

no|plot_annotation|comment|t_start|t_stop|R|ϵ
---|---|---|---|---|---|---
1|first discharge|first discharge – 1|1|4|5|
2|second discharge|second discharge – 2|6|12|5|
3|third discharge|third discharge – 3|14|20|0.5|4.5

Those are the respective parameters for three data subsets to be analysed. Note that the cells in the first two rows of the last column (`ϵ`) are empty, meaning the default value as defined in the previous table will be used.

In this case the actual data are added by the user as the third table of the same excel file.

The user then runs in the terminal another batch file, here called `rcex.bat`, and gets the following dialog.

```
eben@Macni2020M1 RcExample % ./rcex.sh 
press <ENTER>, then select excel file.
RcExample> 
```
Here a file selection dialog opens for the user to point to the formerly prepared excel file. You select the file, it will be processed, and you will be prompted for the next one:

```
Completed processing /Users/eben/Julia/GivEmExel.jl/examples/RcExample/RcExample.jl/data/RcExampleData.xlsx
press <ENTER> to process next file, of -a<ENTER> to abort 
RcExample> -a
eben@Macni2020M1 RcExample % 
```

If unsure, it is possible to enter `-h` or `--help` at any stage of the dialog.

As soon as the selected file is processed, the results will be put into a folder named *`YourExcelFileName`*`_rslt`: There will be an excel file with the processing results (in this case containing two tables: one table with one results row per subset, and the summary table), and some graphic files: in this case an overview plot and one plot for each subset.

Clean your data, rinse, repeat 😁

### From the developer's point of view

After, or in the course of, finishing to program what your package is expected to do, define the parameter and units to be communicated to your app. Those can be transferred by way of CLI parameter, or through a file in XLSX format. In our toy example the plotting format can be passed as CLI parameter, e.g.
```
$ >  rcex.sh --plotformat PDF
```
whereas for the experiment parameters like `area` and `ϵ`, we use excel. However, in the end the CLI input will be merged with the excel input and passed to your functions as `kwargs...`

In our example, the experimental data are in a separate table in the same excel file. We could also let the user to point to a separate file or folder, or conclude to the data file from the name or position of the excel file.

It is assumed (but not required) that your calculation processes multiple data subsets: In our example there are three segments (three capacitor discharges).  We divide our processing into three separate functions: Preprocessing / processing each subset / postprocessing. In our toy example these functions are: `preproc`, `procsubset`, `postproc`. You can however skip some steps if you don't need them. In our toy example you can uncomment the line 
```
# postproc = nothing 
```
just with the effect that no summary will now be produced. Our functions are expected to return dataframes or dataframe rows, and plot objects. In our example, we use `Plots.jl`. `Makie.jl` is also supported out of the box. For other plotting packages, you will need to add a few code lines.

The returned dataframes will be saved as an excel file with multiple tables, the plots saved in the selected format. Voilà!
