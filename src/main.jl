using Pkg
basedir = splitdir(@__DIR__)[1]
Pkg.activate(basedir)

using GivEmExel

rslt = repl(; basedir)
;