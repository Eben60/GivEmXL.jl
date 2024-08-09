# preferrably you should start Julia with the corresponding project using a batch script
# to save a second or two on environment switching on start time.
#
# Just for the case you didn't, we check the environment and activate the proper one if necessary.

using Pkg, DataFrames

pkg_name = "NoXLexample"

if isnothing(Pkg.Types.Context().env.pkg) || Pkg.Types.Context().env.pkg.name != pkg_name
    Pkg.activate(dirname(@__DIR__))
end

using NoXLexample
using GivEmXL

#  dialogtype ∈ [:single, :multiple, :folder]

procsubset = postproc = nothing

complete_interact(pp0, pps, (preproc, procsubset, postproc); 
    getexel=false, getdata=(; dialogtype = :single, filterlist="csv"))
