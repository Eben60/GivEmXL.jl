using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

if isfile(joinpath(basedir, "../../../", "src/GivEmExel.jl"))
    parentdir = joinpath(basedir, "../../../")
    Pkg.develop(path=parentdir)
end

Pkg.instantiate()
;
