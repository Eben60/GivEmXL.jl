using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(path=(joinpath(@__DIR__, "../") |> normpath))

using Documenter
using GivEmExel

# generate documentation locally. 
# keep in mind .gitignore - deps/deps.jl
makedocs(
    modules = [GivEmExel],
    format = Documenter.HTML(; prettyurls = (get(ENV, "CI", nothing) == "true")),
    authors = "Eben60",
    sitename = "GivEmExel.jl",
    pages = Any[
        "Introduction" => "index.md", 
        "API user interaction" => "api_user-interaction.md",
        "API data processing" => "api_data-processing.md",
        "Toy Example: Fit exp decay curves" => "rc_example.md",
        "Docstrings" => "docstrings.md"
        ],
    checkdocs = :exports, 
    warnonly = [:missing_docs],
    # strict = true,
    # clean = true,
)
;

# deployment done on the server anyway
# don't normally run deploydocs here
# deploydocs(
#     repo = "github.com/Eben60/SimpleArgParse.jl.git",
#     versions = nothing,
#     push_preview = true
# )
