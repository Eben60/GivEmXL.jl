using RcExample
using GivEmExel, GivEmExel.SavingResults 

# Macni2020M1 RcExample.jl % julia --project=. src/rcex.jl -e --plotformat none

fn(; kwargs...) = proc_n_save(procwhole, procsubset; kwargs...)

fi = complete_interact(pp0, pps, fn; getexel=true, getdata=(; dialogtype = :none))
