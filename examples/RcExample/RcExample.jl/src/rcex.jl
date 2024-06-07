using RcExample
using GivEmExel

# Macni2020M1 RcExample.jl % julia --project=. src/rcex.jl -e --plotformat none



fi = complete_interact(pp0, pps, process_and_save; getexel=true, getdata=(; dialogtype = :none))
