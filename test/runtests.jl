using GivEmExel
using Test, Unitful, OrderedCollections, Aqua, DataFrames

using GivEmExel: merge_params, nt_skipmissing, read_units, mergent, s2unit, nt_skipmissing, nt2unitful, mergent, 
    exper_paramsets, combine2df, out_paths

if !(isdefined(@__MODULE__, :complete_tests) && !complete_tests) 
    Aqua.Aqua.test_all(GivEmExel; ambiguities = false)
    @test isempty(Test.detect_ambiguities(GivEmExel))
end

@testset "GivEmExel" begin

p = joinpath(@__DIR__, "..", "data/testset.xlsx")
(;df_setup, df_exp) = read_xl_paramtables(p)
(nt1, nt_exp1, nt_setup) = merge_params(df_exp, df_setup, 1) # subset 1
(nt2, nt_exp2, ) = merge_params(df_exp, df_setup, 2) # subset 2

@test isequal(read_units(df_setup), (; area = u"cm^2", vol = u"mL", temp = u"°C", δvol = missing, p₁ = u"bar", 
                                p₂ = u"bar", V = u"kV", I = u"mA", I0 = u"μA", c = missing))

@test nt1.area |> ustrip == nt_setup.area
@test nt_setup.area == 13
@test nt2.area |> ustrip == nt_exp2.area
@test nt_exp2.area == 15

userargs = (;plotformat="none")
p_sets = exper_paramsets(userargs, df_exp, df_setup)
@test p_sets[1].area == 13u"cm^2"
@test p_sets[2] == (plotformat = "none", area = 15u"cm^2", vol = 20u"mL", 
    temp = 36.9u"°C", p₁ = 10.1u"bar", p₂ = 0.9u"bar", V =u"kV", I =u"mA", I0 = 18u"μA", 
    δvol = 0.01, c = "PNG", no = 2, plot_annotation = "8 bar empty", 
    comment = "8 bar, second run, empty", start = 120, stop = 200, timings = 150)

@test nt_skipmissing((;a=1.0, b=missing, c=2)) == (;a=1.0, c=2)

@test mergent([:a=>1, :b=>2], (;a="7"), [:c=>8]) == (;a="7", b=2, c=8)

@test s2unit("cm^2/s") == u"cm^2/s"
@test s2unit("\'cm^2/s‟") == u"cm^2/s"

@test nt_skipmissing((; a=1, b=2, c=missing, d=3)) == (; a=1, b=2, d=3)

@test nt2unitful((; a=2.0, b=3), (;a=u"cm/s")) == (a = 2.0u"cm/s", b = 3)

ntmerged = (;a = 1, b = 2, c = 3, d = 4, e = 6, f = 7)
@test mergent((;a=1, b=2), OrderedDict(:c => 3, :d => 4), [:e => 6, :f => 7]) == ntmerged
@test mergent([(;a=1, b=2), OrderedDict(:c => 3, :d => 4), [:e => 6, :f => 7]]) == ntmerged

@test isnothing(combine2df([((;a=1, b=2)), (;a=3, b=4)]))
df = combine2df([(;df_row=(;a=1, b=2)), (;df_row=(;a=3, b=4))])
@test df == DataFrame(a=[1,3], b=[2,4])

f_src = "/foo/bar/notadir/notafile.xlsx"

@test_throws ErrorException out_paths(f_src; fakefile=true)


end
;