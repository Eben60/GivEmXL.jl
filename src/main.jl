using Pkg
basedir = splitdir(@__DIR__)[1]
Pkg.activate(basedir)

using GivEmExel


# @show cl_args
rslt = repl(parse_commandline; ) # basedir)
;