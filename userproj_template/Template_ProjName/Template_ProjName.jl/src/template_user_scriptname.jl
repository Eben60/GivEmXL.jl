
# preferrably you should start Julia with the corresponding project using a batch script
# to save a second or two on environment switching on start time.
#
# Just for the case you didn't, we check the environment and activate the proper one if necessary.

using Pkg

pkg_name = "Template_ProjName"

if isnothing(Pkg.Types.Context().env.pkg) || Pkg.Types.Context().env.pkg.name != pkg_name
    Pkg.activate(dirname(@__DIR__))
end

using Template_ProjName
using GivEmExel

# Macni2020M1 Template_ProjName.jl % julia --project=. src/template_user_scriptname.jl -e --plotformat none

complete_interact(pp0, pps, (preproc, procsubset, postproc); getexel=true, getdata=(; dialogtype = :none))
