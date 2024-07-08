function copy_proj(src_folder, tgt_folder, old_proj_name, td; force, new_proj_name=nothing)
    cp_folder = joinpath(tgt_folder, old_proj_name)

    if force
        oldnewfolder = joinpath(tgt_folder, new_proj_name)
        isdir(oldnewfolder) && rm(oldnewfolder; recursive=true)
    end

    cp(src_folder, cp_folder; force)

    proj_dir = joinpath(cp_folder, (old_proj_name * ".jl"))
    proj_toml = joinpath(proj_dir, "Project.toml")
    @assert isfile(proj_toml)

    open(proj_toml, "w") do io
        TOML.print(io, td)
    end

    mnf_toml = joinpath(proj_dir, "Manifest.toml")
    isfile(mnf_toml) && rm(mnf_toml)

    return nothing
end

function repl_in_files(f, old_substring, new_substring)

    content = read(f, String)

    modified_content = replace(content, old_substring => new_substring)
    
    open(f, "w") do file
        write(file, modified_content)
    end
    return nothing
end
export repl_in_files

function rename_file(f, oldprefix, newprefix)
    dir = dirname(f)
    fname = basename(f)
    @assert startswith(fname, oldprefix)
    newname = replace(fname, oldprefix => newprefix)
    newpath = joinpath(dir, newname)
    mv(f, newpath)
end

function hassuffix(fname, suffixes)
    for s in suffixes
        endswith(lowercase(fname), lowercase(s)) && return true
    end
    return false
end

function list_files_with_suffixes(root_dir, suffixes=[".jl", ".bat", ".sh"])
    files = String[]
    for (root, _, filenames) in walkdir(root_dir)
        for filename in filenames
            if hassuffix(filename, suffixes)
                push!(files, joinpath(root, filename))
            end
        end
    end
    return files
end

function matchname(fname, prefix; ignorecase=true, exact=false)
    if ignorecase 
        fname = lowercase(fname)
        prefix = lowercase(prefix)
    end

    startswith(fname, prefix) || return false
    ! exact && return true

    return splitext(fname)[1]==prefix
end

function files_starting_with(root_dir, prefix; ignorecase=true, exact=false)
    files = String[]
    dirs = String[]

    for (root, dirnames, filenames) in walkdir(root_dir)
        for filename in filenames
            matchname(filename, prefix; ignorecase, exact) && push!(files, joinpath(root, filename))
        end
        for dirname in dirnames
            matchname(dirname, prefix; ignorecase, exact) && push!(dirs, joinpath(root, dirname))
        end
    end

    return (;files, dirs)
end

function makeproj(tgt_folder, new_proj_name, tgt_script; 
    ignorecase=true, authors::Vector{String}=String[], src_folder=nothing, src_script=nothing, force=false)

    @assert isdir(tgt_folder)

    if isnothing(src_folder) 
        error("define source!")
    end

    @assert isdir(src_folder)

    src_proj = basename(src_folder)
    src_proj_toml = joinpath(src_folder, (src_proj * ".jl"), "Project.toml")
    @assert isfile(src_proj_toml)

    td = TOML.parsefile(src_proj_toml)
    # td0 = deepcopy(td)

    old_proj_name = td["name"]
    @assert uppercase(src_proj) == uppercase(old_proj_name)

    td["name"] = new_proj_name
    td["uuid"] = string(UUIDs.uuid4())
    td["authors"] = authors

    copy_proj(src_folder, tgt_folder, old_proj_name, td; force, new_proj_name)

    fls = files_starting_with(tgt_folder, old_proj_name; ignorecase)

    for f in fls.files
        rename_file(f, old_proj_name, new_proj_name)
    end

    dirs = sort(fls.dirs; by=(x -> length(splitpath(x))), rev=true) # start renaming from the most nested dirs
    for f in dirs
        rename_file(f, old_proj_name, new_proj_name)
    end

    bashdir = joinpath(tgt_folder, new_proj_name)
    @assert isdir(bashdir)
    projdir = joinpath(bashdir, (new_proj_name * ".jl"))
    @assert isdir(projdir)
    srcfls = list_files_with_suffixes(bashdir)

    for f in srcfls
        repl_in_files(f, old_proj_name, new_proj_name)
        repl_in_files(f, src_script, tgt_script)
    end

    for f in files_starting_with(tgt_folder, src_script; ignorecase=true, exact=true).files
        rename_file(f, src_script, tgt_script)
    end

    return (;td, fls, srcfls) #, td0)
end

