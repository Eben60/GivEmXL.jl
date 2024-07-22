using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

# Pkg.add(; path="/Server/InHouse_Software/AnotherInHouseProj.jl/")

Pkg.develop(; path=joinpath(basedir, "included_packages/OurInHouseProj.jl/"))

Pkg.instantiate()
;
