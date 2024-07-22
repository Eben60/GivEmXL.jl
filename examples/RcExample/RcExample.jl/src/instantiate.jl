using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

Pkg.instantiate()
;
