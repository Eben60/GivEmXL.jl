using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)


# Pkg.add(path="included_packages/MyBespokeProject.jl/")


Pkg.instantiate()
;
