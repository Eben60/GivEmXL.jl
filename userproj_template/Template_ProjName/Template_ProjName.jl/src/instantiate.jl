using Pkg

basedir = joinpath(@__DIR__, "..") |> normpath
Pkg.activate(basedir)

# Pkg.add(; path="/Server/InHouse_Software/AnotherInHouseProj.jl/")

# you can safely remove the following block if you do not include any nested packages
begin
    incl_dir = joinpath(basedir, "included_packages/")
    nested = filter(isdir, joinpath.(Ref(incl_dir), readdir(incl_dir)) )

    for p in nested
        Pkg.develop(; path=p)
    end
end

Pkg.instantiate()
;
