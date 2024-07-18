using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

if isfile(joinpath(basedir, "../../../", "src/GivEmXL.jl"))
    parentdir = joinpath(basedir, "../../../")
    Pkg.develop(path=parentdir)
end

Pkg.instantiate()
;
