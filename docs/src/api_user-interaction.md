## API user interaction

The user interaction API is based on a modified version of the package `SimpleArgParse.jl`. It is in principle agreed with the author of `SimpleArgParse.jl` to merge the changes I made to the package as v2, however for the time being I just included it into `GivEmExcel.jl` as a sub-package. For the documentation of `SimpleArgParse.jl v2` (still WIP) see [here](https://htmlpreview.github.io/?https://github.com/Eben60/SimpleArgParse.jl/blob/maindev/docs/build/index.html).

The both functions [`proc_ARGS`](@ref GivEmExel.proc_ARGS) and [`prompt_and_parse`](@ref GivEmExel.prompt_and_parse) take an `ArgumentParser` (as defined in [`SimpleArgParse`](https://htmlpreview.github.io/?https://github.com/Eben60/SimpleArgParse.jl/blob/maindev/docs/build/index.html) ); they can also be passed `Nothing` - in this case the corresponding step will be skipped. Please see in our [Toy Example](@ref "Toy Example: Fit exp decay curves") for how in a typical case practically to define the interaction with the user.

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
using GivEmExel

complete_interact(pp0, pps, (preproc, procsubset, postproc); getexel=true, getdata=(; dialogtype = :none))
```

For details, see [`complete_interact` documentation](@ref GivEmExel.complete_interact) and the first of the flow charts above. The parameter `pp0` and `pps`, defining the user interaction, and the functions `preproc`, `procsubset`, `postproc` are to be defined in and exported from your package `MyBespokePackage`.

### Batch scripts

Copy and if necessary adjust the relevant scripts (`.bat` for Windows, `.sh` for Linux/mac) from the Toy Example. These scripts do nothing else but execute Julia with the corresponding julia script.

### Any questions?

Please analyze the [Toy Example](@ref "Toy Example: Fit exp decay curves").