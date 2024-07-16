using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(path=(joinpath(@__DIR__, "../") |> normpath))

using Documenter
using GivEmExel

# generate documentation locally. 
makedocs(
    modules = [GivEmExel],
    format = Documenter.HTML(; prettyurls = (get(ENV, "CI", nothing) == "true")),
    authors = "Eben60",
    sitename = "GivEmExel.jl",
    pages = Any[
        "Introduction" => "index.md", 
        "API data processing" => "api_data-processing.md",
        "API user interaction" => "api_user-interaction.md",
        "Toy Example: Fit exp decay curves" => "rc_example.md",
        "Creating project from template" => "create-from-template.md",
        "Finally" => "finally.md", 
        "Docstrings" => "docstrings.md"
        ],
    checkdocs = :exports, 
    warnonly = [:missing_docs],
    # strict = true,
    # clean = true,
)

