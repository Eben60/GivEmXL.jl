using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

# Pkg.add(; url="https://github.com/Eben60/GivEmXL.jl")

# Pkg.add(; path="/Server/InHouse_Software/AnotherInHouseProj.jl/")

Pkg.develop(; path=joinpath(basedir, "included_packages/OurInHouseProj.jl/"))

Pkg.instantiate()
;
