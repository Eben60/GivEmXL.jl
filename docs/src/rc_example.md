## Toy Example: Fit exp decay curves

### Parameter definition

Actually we already have discussed the both tables [here](@ref "From the point of view of user"), please re-read the section. The corresponding file is under [`examples/RcExample/RcExample.jl/data/RcExampleData.xlsx](https://github.com/Eben60/GivEmExel.jl/blob/main/examples/RcExample/RcExample.jl/data/RcExampleData.xlsx).

### Parameter passed to data processing functions
- `xlfile::String`: path to the exel file (in general case, `Union{Nothing, String}`)
- `datafiles::Nothing`: we put our data into the same exel file (in general case, `Union{Nothing, String, Vector{String}}`)
- `paramsets::Vector{NamedTuple}`: In our case, there will be 3 NamedTuples, one for each row of the table `params_experiment`. Each NamedTuple will contain the data as defined in the corresponding row as well a (repeating) data from the user input (here only `plotformat` defined) and the table table `params_experiment`, e.g. 
```
julia> paramsets[1]
(plotformat = "png", throwonerr = true, area = 0.5 cm², Vunit = mV, timeunit = s, Cunit = nF, R = 5 GΩ, t_start = 1 s, t_stop = 4 s, ϵ = 3.7, no = 1, plot_annotation = "first discharge", comment = "first discharge – 1")
```

### Preprocessing

The function `preproc(xlfile, datafiles, paramsets)` is defined in the file [`examples/RcExample/RcExample.jl/src/RcExample_specific.jl](https://github.com/Eben60/GivEmExel.jl/blob/main/examples/RcExample/RcExample.jl//src/RcExample_specific.jl). We have the free choice in respect to the name of the function. The function must take three arguments discussed above, however in our case it actually uses the first one only and ignores the other. It reads the data from the table `data` of the same excel file, produces a overviews plot using the package `Plots`. The function and returns a NamedTuple of NamedTuples as following: