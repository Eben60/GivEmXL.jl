using RcExample
using GivEmExel

# Macni2020M1 RcExample.jl % julia --project=. src/rcex.jl -e --plotformat none

complete_interact(pp0, pps, (preproc, procsubset, postproc); getexel=true, getdata=(; dialogtype = :none))
