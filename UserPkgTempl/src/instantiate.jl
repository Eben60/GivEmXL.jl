using Pkg
basedir = splitdir(@__DIR__)[1]
Pkg.activate(basedir)
Pkg.instantiate()
;
