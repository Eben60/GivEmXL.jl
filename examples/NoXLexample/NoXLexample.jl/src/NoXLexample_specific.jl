# here goes your actual work
using DataFrames, CSV, Glob, Plots

function preproc(ignoreable, datafiles, paramsets) 

    params = paramsets[1]
    start = params.start
    lastrow = params.lastrow

    multiselect = datafiles isa Vector{T} where T <: AbstractString

    if ! multiselect
        datafiles = isdir(datafiles) ? glob("*.csv", datafiles) : [datafiles]
    end

    symnames = [Symbol(splitext(basename(d))[1]) for d in datafiles]
    dfs = [DataFrame(CSV.File(d)) for d in datafiles]

    dfs = [df[start:min(lastrow, nrow(df)), :] for df in dfs]

    pls = [plot(df.X, df.Y) for df in dfs]

    dataframes = NamedTuple([s => df for (s, df) in zip(symnames, dfs)])
    plots = NamedTuple([s => pl for (s, pl) in zip(symnames, pls)])

    return (;plots, dataframes, data=nothing)
end