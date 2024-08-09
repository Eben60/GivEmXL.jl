using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

# Pkg.add(; path="/Server/InHouse_Software/AnotherInHouseProj.jl/")

Pkg.instantiate()
;
