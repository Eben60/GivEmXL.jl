## Toy Example: Fit exp decay curves

We read the both parameter tables and the data all from the same excel file. The data is a `y(t)` dependence containing several spans of exponential decay which we fit by non-linear least squares according to the formula `a * exp(-(x-t₀)/τ)`, where `t₀` is the span beginning and not fitted. The decay represents a capacitor discharge over a known resistor `R`. From `τ`, we get `C`, and by given `area` and `ϵ` we calculate the thickness of the capacitors dielectric.

We plot an overview plot of the data as well as plots of each span. The span start and end are the subset parameter from the table "params_experiment". The results are saved into two tables of an excel file: "`SubsetsRslt`" and "`summary`".

### User interaction

The user runs from from a terminal window a batch script `rcex.sh` / `rcex.bat` (invoking `rcex.jl`), to which he can optionally provide parameter `-p` / `--plotformat`, `-e` / `--throwonerr`, and `-h` / `--help`. These options are defined through the variable `pp0::YAArguParser.ArgumentParser` which is initialized in the file `init_cli_options.jl`. The user will be asked to point to "his" excel file with the parameters and data, and a GUI dialog opens. There are three excel files provided in the folder `data/` of the example package. You may try it first with the file `RcExampleData.xlsx`.

Upon processing and saving the results, a corresponding message is printed, and either next file can be selected, or processing finished by typing `-a` / `--abort`. These interactions are defined by the variable `pps`, which is a `NamedTuple` of `ArgumentParser`s.

### Processing functions

We define following functions in the file `RcExample_specific.jl`
- `preproc`: Reads the data into a `DataFrame` to be passed downstream, and produces the overview plot-
- `procsubset`: Does the fit on each span, and makes a plot.
- `postproc`: Applies `DataFrames` statistics to the results.

### User invoked script

The `rcex.jl` has just one executable line (apart from the `using` statements). We have already discussed most of the parameters passed to the [`complete_interact`](@ref GivEmXL.complete_interact) function. `getexel=true` and `getdata=(; dialogtype = :none)` tell that there should be a GUI dialog for excel file only.

### Error processing

There are two more excel files there: in `MissingData.xlsx`, some `y` values are missing in one of the spans, wheras in `BrokenData.xlsx` the expected `data` table is missing completely. In the first case, the data is processed as far as possible, and error information saved into the file named `MissingData_err.txt`, and in the second, only the file `BrokenData_err.txt` will be saved. If the flag `--throwonerr` was provided, the program would throw on the first error with the usual screenfull of information.

### Development process

See file `noninteractive_test.jl` for how to supply the parameters to your processing functions in the course of the development process.