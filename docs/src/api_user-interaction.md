## API user interaction

The user interaction API is based on the [`YAArguParser`](https://eben60.github.io/YAArguParser.jl/) package.

The both functions [`proc_ARGS`](@ref GivEmXL.proc_ARGS) and [`prompt_and_parse`](@ref GivEmXL.prompt_and_parse) take an [`ArgumentParser`](https://eben60.github.io/YAArguParser.jl/docstrings/#YAArguParser.ArgumentParser) as an argument; they can also be passed `Nothing` - in this case the corresponding step will be skipped. Please see in our [Toy Example](@ref "Toy Example: Fit exp decay curves") for how to implement the user interaction in a typical case.

### Flow chart - overview 

![Overview](assets/flow_chart-overview.svg)

### Flow chart of proc\_ARGS() function 

![proc_args](assets/flow_chart-proc_ARGS.svg)

### Flow chart of prompt\_and\_parse() function 

![prompt_and_parse](assets/flow_chart-prompt_and_parse.svg)

### User julia script

The script to be invoked by the used user can be as short as

```
using MyBespokePackage
using GivEmXL

complete_interact(pp0, pps, (preproc, procsubset, postproc); getexel=true, getdata=(; dialogtype = :none))
```

For details, see [`complete_interact` documentation](@ref GivEmXL.complete_interact) and the first of the flow charts above. The parameter `pp0` and `pps`, defining the user interaction, and the functions `preproc`, `procsubset`, `postproc` are to be defined in and exported from your package `MyBespokePackage`.

### Batch scripts

Batch scripts do nothing else but execute Julia in the environment you supplied, with the corresponding julia script.

### Any questions?

Please analyze the [Toy Example](@ref "Toy Example: Fit exp decay curves").