using Pkg, Coverage
parentdir = joinpath(@__DIR__ , "..")  |> normpath
lcovinfo = joinpath(parentdir, "lcov.info")
Pkg.activate(@__DIR__)

# don't forget to execute pkg> test --coverage
# on the project under development

using Suppressor
lcovdata = nothing
@suppress begin
    global lcovdata
    lcovdata = process_folder(parentdir)
end
LCOV.writefile(lcovinfo, lcovdata)
@suppress begin
    Coverage.clean_folder(parentdir)
end
Pkg.activate(parentdir)
;