using Pkg
basedir = splitdir(@__DIR__)[1]
Pkg.activate(basedir)

if isfile(joinpath(basedir, "../../", "src/GivEmExel.jl"))
    parentdir = joinpath(basedir, "../../")
    Pkg.develop(path=parentdir)
end

Pkg.instantiate()
;
