module SavingResultsMakieExt

using Makie
using GivEmExel
import GivEmExel: isplot, save_plot

MakiePlot = Union{Makie.Figure, Makie.FigureAxisPlot, Makie.AbstractScene, Makie.AbstractPlot}
# Makie.AbstractPlot actually not supported for saving by Makie
# but that's not our problem

isplot(::P ) where P <: MakiePlot = true
save_plot(pl::P, fl) where P <: MakiePlot = Makie.save(fl, pl)

end