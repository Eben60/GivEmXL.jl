## Toy Example #2: Read CSV, no excel

We read one or multiple CSV files, plot the data and save the contents of these CSV files into (multiple) table(s) of an excel file.

### Location in `GivEmXL` project

`"examples/NoXLexample"`

### User interaction

The user runs from from a terminal window a batch script `csvread.sh` / `csvread.bat` (invoking `csvread.jl`), to which he can optionally provide parameter `-s` / `--start`, `-l` / `--lastrow` (defining the data subset), `-e` / `--throwonerr`, and `-h` / `--help`. These options are defined through the variable `pp0::YAArguParser.ArgumentParser` which is initialized in the file `init_cli_options.jl`. The user will be asked to point to "his" CSV file(s), and a GUI dialog opens. There are two CSV files provided in the folder `data/` of the example package. 

The type of the file dialog is defined in the line `22` of the file `csvread.jl`: `dialogtype = :single`. You can replace it by `:multiple` or `:folder`. In the last case, all CSV files in the selected folder will be processed.

Upon processing and saving the results, a corresponding message is printed, and either next file can be selected, or processing finished by typing `-a` / `--abort`. These interactions are defined by the variable `pps`, which is a `NamedTuple` of `ArgumentParser`s.

### Processing functions

We define following just one processing function in the file `NoXLexample_specific.jl`
- `preproc`: Reads the CSV data into `DataFrames` to be passed downstream, and produces plots

`procsubset` and `postproc` are both set to `nothing` in `csvread.jl`

### User invoked script

The `csvread.jl` calls [`complete_interact`](@ref GivEmXL.complete_interact) function. We have already discussed most of the parameters passed to it function. `getexel=false` and `getdata=(; dialogtype = :single, filterlist="csv")` tell that there should be a GUI dialog for data file(s) only.

### Error processing

There are two more excel files there: in `MissingData.xlsx`, some `y` values are missing in one of the spans, wheras in `BrokenData.xlsx` the expected `data` table is missing completely. In the first case, the data is processed as far as possible, and error information saved into the file named `MissingData_err.txt`, and in the second, only the file `BrokenData_err.txt` will be saved. 

If the flag `--throwonerr` was provided, the program would throw on the first error with the usual screenfull of information, otherwise the data will processed as far as possible, and error information saved into a file in the results folder.

### Development process

See file `noninteractive_test.jl` for how to supply the parameters to your processing functions in the course of the development process.