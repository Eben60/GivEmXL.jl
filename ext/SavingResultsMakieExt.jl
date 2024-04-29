module SavingResultsMakieExt

using GivEmExel

using Makie

isplot(::P ) where P <: Makie.Figure = true

_saveplot(pl::P, fl) where P <: Makie.Figure= Makie.save(fl, pl)

end