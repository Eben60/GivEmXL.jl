using RcExample
using GivEmExel

# Macni2020M1 RcExample.jl % julia --project=. src/rcex.jl -e --plotformat none

fn(; kwargs...) = proc_n_save(preproc, procsubset, postproc; kwargs...)

fi = complete_interact(pp0, pps, fn; getexel=true, getdata=(; dialogtype = :none))
