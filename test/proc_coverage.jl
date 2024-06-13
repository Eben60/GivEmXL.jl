using Pkg
parentdir = joinpath(@__DIR__ , "..")  |> normpath
Pkg.activate(parentdir)
Pkg.test(; coverage=true)

Pkg.activate(@__DIR__)

# don't forget to execute pkg> test --coverage
# on the project under development

using Pkg, Coverage, Suppressor
lcovdata = nothing
lcovinfo = joinpath(parentdir, "lcov.info")
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