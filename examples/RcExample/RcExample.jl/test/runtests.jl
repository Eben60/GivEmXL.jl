using Test, Unitful
using Unitful: ϵ0

using Pkg, UUIDs

pkg_name = "RcExample"
pkg_uuid = UUID("860fe72d-ead5-40a6-888e-a6a0dafefe10")

pkg_available = ! isnothing(Pkg.Types.Context().env.pkg) && Pkg.Types.Context().env.pkg.name == pkg_name
pkg_available = pkg_available || haskey(Pkg.dependencies(), pkg_uuid)

if ! pkg_available
    rcexample_dir = dirname(@__DIR__)
    Pkg.activate(rcexample_dir)
end

using RcExample
using RcExample: calc_thickness

@testset "RcExample" begin

@test isapprox(calc_thickness(100.0u"pF", 3.5, 1.0u"cm^2"), 31.0u"μm"; rtol=1e-3) 

end
;