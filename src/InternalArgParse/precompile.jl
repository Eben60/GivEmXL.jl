using PrecompileTools: @setup_workload, @compile_workload 

# @compile_workload begin

    rvl = RealValidator{Int}(;excl_vals=[1, 2], excl_ivls=[(10, 15), (20, 25)], incl_vals=[3, 4, 11], incl_ivls=[(100, typemax(Int))])
    svl = StrValidator(; upper_case=true, patterns=["aaa", "BBB"])

    p = ArgumentParser(
        description="test",
        authors=["first last <first.last@foo.bar>"],
        documentation="server/docs",
        repository="server/repo",
        license="license",
        usage="julia main.jl --arg val",
        add_help=true,
        color = "magenta",
        )

    add_argument!(p, "-p", "--pos", type=String, positional=true, description="positional")
    add_argument!(p, "-f", "--foo", type=String, default="bar", description="baz")
    add_argument!(p, "-i", "--int", type=Int, validator=rvl, description="real validation")
    add_argument!(p, "-s", "--soo", type=String, validator=svl, description="string validation")
    set_value!(p, "--foo", "aaa")
    set_value!(p, "-i", 3)
    set_value!(p, "-s", "aaa")
    parse_args!(p; cli_args=["posarg", "-f", "fff", "-int", "111", "-soo", "bbb"])
    get_value(p, "-i")
    args_pairs(p)

# end