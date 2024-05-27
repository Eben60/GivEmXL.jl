# GivEmExel - build your poor man's interactive app

## Package purpose

Let's assume you are the only `Julia`  user/programmer among your colleagues. Actually the only one who does programming at all -- all others mostly use Excel for their computations, or else some specialized (GUI) software. 

Now, you have developed a script for some computation or data analysis which they would be glad to use -- but asking them to accept your programmers workflow would be asking too much. Building a full GUI for your script to be used by a merely couple of users would be an expensive overkill. Enter `GivEmExel`: with this package you are able to produce "somewhat interactive" packages for use by your non-programming colleagues.

## Toy example - evaluation of capacitor discharge curves

See the source under `examples/RcExample`

### From the point of view of user

Your colleague receives from you
* Instructions on `Julia` installation on their computer
* An Excel (compatible) template file containing one or two tables
* A folder to be copied somewhere onto their computer. The folder contains two batch files (`.bat` on Windows an `.sh` on unixes), and some other folder enclosed. One of the batch files is `instantiate.bat` to be run once.

Let's look onto the contents of the Excel files. The first of them is called `param_setup` and contains the default values (here for `area` and `ϵ`) and the units like following:

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

Those are the respective parameters for three data subsets to be analysed. Note in the last column (`ϵ`) the cells in the first two rows are empty, meaning the default value as defined in the previous table will be used.

In this case the actual data are added by the user as the third table of the same Excel file.

The user then runs in the terminal another batch file, here called `rcex.bat`, and gets the following dialog.

```
eben@Macni2020M1 RcExample % ./rcex.sh 
press <ENTER>, then select Excel file.
RcExample> 
```
Here a file selection dialog opens, and he will point to the formerly prepared Excel file.

```
Completed processing /Users/eben/Julia/GivEmExel.jl/examples/RcExample/RcExample.jl/data/RcExampleData.xlsx
press <ENTER> to process next file, of -a<ENTER> to abort 
RcExample> -a
eben@Macni2020M1 RcExample % 
```

Entering -h or --help at any stage of the dialog helps:


```
eben@Macni2020M1 RcExample % ./rcex.sh -h

Usage:  [-p|--plotformat <String>] [-e|--throwonerr] [-h|--help]

Command line options parser

Options:
  -p, --plotformat <String>	Accepted file format: PNG (default), PDF, SVG or NONE
  -e, --throwonerr		If false, exceptions will be caught and stacktrace saved to file. If true, program run interrupted, and stacktrace printed. Default is false
  -h, --help		Print the help message.

Examples:
  $ >  rcex.sh --plotformat NONE
  $ >  rcex.sh -e
  $ >  rcex.sh --help

eben@Macni2020M1 RcExample %
```

```
eben@Macni2020M1 RcExample % ./rcex.sh   
press <ENTER>, then select Excel file.
RcExample> -h

Usage:  [-a|--abort] [-h|--help]

Prompt for Excel file

Options:
  -a, --abort		Abort switch.
  -h, --help		Print the help message.
```

As soon as the selected file is processed, the results will be put into a folder named YourExcelFileName_rslt: There will be an Excel file with the processing results (in this case containing two tables, one with one results row per subset, and one summary table), and some graphic files: in this case an overview plot and one plot for each subset.

Clean your data, rinse, repeat 😁

### From the point of view of developer

