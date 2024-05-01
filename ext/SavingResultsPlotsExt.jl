module SavingResultsMakieExt

using Plots

using GivEmExel.SavingResults
import GivEmExel.SavingResults: isplot, save_plot

isplot(::P ) where P <: Plots.Plot = true

save_plot(pl::P, fl) where P <: Plots.Plot = savefig(pl, fl)

end