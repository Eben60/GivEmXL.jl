using Pkg, TOML

prev_proj = Base.active_project()
Pkg.activate(@__DIR__)
path = joinpath(@__DIR__ , "..") |> normpath

project_toml_path = joinpath(path, "Project.toml")
project_toml = TOML.parsefile(project_toml_path)
parent_proj_name = project_toml["name"]

using Suppressor
@suppress begin
    Pkg.develop(;path)
end

complete_tests = false
errors_occured = false
err_msg = ""
error_class = ""
try
    include("runtests.jl")
catch e
    global err_msg, errors_occured, error_class
    errors_occured = true
    hasproperty(e, :msg) && (err_msg = e.msg)
    error_class = string(Symbol(e))
finally
    @suppress begin
        Pkg.rm(parent_proj_name)
        Pkg.activate(prev_proj)
    end
    errors_occured && println("error $error_class occured in the test suite!")
end
