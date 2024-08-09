using Documenter
using GivEmXL

makedocs(
    modules = [GivEmXL],
    format = Documenter.HTML(; prettyurls = (get(ENV, "CI", nothing) == "true")),
    authors = "Eben60",
    sitename = "GivEmXL.jl",
    pages = Any[
        "Introduction" => "index.md", 
        "API data processing" => "api_data-processing.md",
        "API user interaction" => "api_user-interaction.md",
        "Toy Example #1: Fit exp decay curves" => "rc_example.md",
        "Toy Example #2: Read CSV, no excel" => "noxl_example.md",    
        "Creating project from template" => "create-from-template.md",
        "Finally" => "finally.md", 
        "Docstrings" => "docstrings.md"
        ],
    checkdocs = :exports, 
    warnonly = [:missing_docs],
    # strict = true,
    # clean = true,
)

deploydocs(
    repo = "github.com/Eben60/GivEmXL.jl.git",
    versions = nothing,
    push_preview = true
)
;