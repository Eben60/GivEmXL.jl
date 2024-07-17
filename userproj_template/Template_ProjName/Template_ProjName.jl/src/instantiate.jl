using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

# Pkg.add(; path="/Server/InHouse_Software/AnInHouseProj.jl/")

Pkg.develop(; path="included_packages/AnInHouseProj.jl/")


Pkg.add(; url="https://github.com/Eben60/GivEmExel.jl")

Pkg.instantiate()
;