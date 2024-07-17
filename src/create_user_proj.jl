function copy_proj(src_folder, tgt_folder, src_projname, proj_tomldict; force=false, tgt_projname=nothing)
    cp_folder = joinpath(tgt_folder, src_projname)

    if force
        oldnewfolder = joinpath(tgt_folder, tgt_projname)
        isdir(oldnewfolder) && rm(oldnewfolder; recursive=true)
    end

    cp(src_folder, cp_folder; force)

    proj_dir = joinpath(cp_folder, (src_projname * ".jl"))
    proj_toml = joinpath(proj_dir, "Project.toml")
    @assert isfile(proj_toml)

    open(proj_toml, "w") do io
        TOML.print(io, proj_tomldict)
    end

    mnf_toml = joinpath(proj_dir, "Manifest.toml")
    isfile(mnf_toml) && rm(mnf_toml)

    return nothing
end

function proj_toml(src_projfolder, tgt_projname, authors)
    src_proj_toml = joinpath(src_projfolder, "Project.toml")
    @assert isfile(src_proj_toml)

    proj_tomldict = TOML.parsefile(src_proj_toml)

    src_projname = proj_tomldict["name"]

    proj_tomldict["name"] = tgt_projname
    proj_tomldict["uuid"] = string(UUIDs.uuid4())
    proj_tomldict["authors"] = authors
    return (; proj_tomldict, src_projname)
end

function repl_in_files(f, oldnew_ps)

    content = read(f, String)

    modified_content = replace(content, oldnew_ps...)
    
    open(f, "w") do file
        write(file, modified_content)
    end
    return nothing
end
export repl_in_files

function rename_file!(f, oldprefix, newprefix)
    dir = dirname(f)
    fname = basename(f)
    @assert startswith(fname, oldprefix)

    oldprefix == newprefix && return nothing
    
    newname = replace(fname, oldprefix => newprefix)
    newpath = joinpath(dir, newname)
    mv(f, newpath)
    return nothing
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


function getsource(tgt_folder, src_folder, src_scriptname)
    @assert isdir(tgt_folder)

    if isnothing(src_folder) 
        src_folder = joinpath(dirname(@__DIR__), "userproj_template", "Template_ProjName")
    end

    if isnothing(src_scriptname)
        src_scriptname = "template_user_scriptname"
    end

    @assert isdir(src_folder)

    src_proj_foldername = basename(src_folder)
    src_projfolder = joinpath(src_folder, (src_proj_foldername * ".jl"))

    @assert isfile(joinpath(src_projfolder, "src", (src_scriptname * ".jl")))

    return (; src_folder, src_scriptname, src_projfolder, src_proj_foldername)
end

function replace_n_rename(; tgt_folder, src_projname, tgt_projname, src_scriptname, tgt_scriptname, ignorecase)
    fls = files_starting_with(tgt_folder, src_projname; ignorecase)

    for f in fls.files
        rename_file!(f, src_projname, tgt_projname)
    end

    dirs = sort(fls.dirs; by=(x -> length(splitpath(x))), rev=true) # start renaming from the most nested dirs
    for f in dirs
        rename_file!(f, src_projname, tgt_projname)
    end

    bashdir = joinpath(tgt_folder, tgt_projname)
    @assert isdir(bashdir)
    projdir = joinpath(bashdir, (tgt_projname * ".jl"))
    @assert isdir(projdir)

    for f in list_files_with_suffixes(bashdir)
        repl_in_files(f, [src_projname=>tgt_projname, src_scriptname=>tgt_scriptname])
    end

    for f in files_starting_with(tgt_folder, src_scriptname; ignorecase=true, exact=true).files
        rename_file!(f, src_scriptname, tgt_scriptname)
    end
end


"""
    makeproj(tgt_folder, tgt_projname, tgt_scriptname, src::NamedTuple; 
        ignorecase=false, authors::Vector{String}=String[], force=false) → nothing
    makeproj(tgt_folder, tgt_projname, tgt_scriptname, src::Symbol; kwargs...)

Create a project by copying a template project and performing renamings as necessary.

# Arguments
- `tgt_folder::AbstractString`: Target folder
- `tgt_projname::AbstractString`: The name of the project to be created
- `tgt_scriptname::AbstractString`: The name of the executable script
- `src::Symbol`: Accepts either `:default` (the default template), of `:example1`, 
    which is the Toy Example provided with `GivEmExel`
- `src::@NamedTuple{src_folder::String, src_scriptname::String}`: E.g. it would be 
    `src=(; src_folder="userproj_template/Template_ProjName", src_scriptname="template_user_scriptname")` 
    for the default template

# Keyword arguments
- `ignorecase=false`: Ignore case in the file paths
- `authors::Vector{T}=String[] where T <: AbstractString`: The project authors (goes to `Project.toml`)
- `force=false`: If true, will overwrite the destination.

Function `makeproj` is public, not exported.
"""
function makeproj(tgt_folder, tgt_projname, tgt_scriptname, src::Symbol = :default; kwargs...) 
    proj_dir = dirname(@__DIR__) 
    if src == :default
        src_folder=(joinpath(proj_dir, "userproj_template/Template_ProjName"))
        src_scriptname="template_user_scriptname"
    elseif src == :example1
        src_folder=(joinpath(proj_dir, "examples/RcExample"))
        src_scriptname="rcex"
    else
        error("Source :$src not implemented")
    end

    return makeproj(tgt_folder, tgt_projname, tgt_scriptname, (;src_folder, src_scriptname); kwargs...)
end

function makeproj(tgt_folder, tgt_projname, tgt_scriptname, src::NamedTuple; 
    ignorecase=false, authors::Vector{T}=String[], force=false) where T <: AbstractString

    (; src_folder, src_scriptname) = src

    (; src_folder, src_scriptname, src_projfolder, src_proj_foldername) = getsource(tgt_folder, src_folder, src_scriptname)

    (;proj_tomldict, src_projname)= proj_toml(src_projfolder, tgt_projname, authors)
    @assert uppercase(src_proj_foldername) == uppercase(src_projname)

    copy_proj(src_folder, tgt_folder, src_projname, proj_tomldict; force, tgt_projname)

    replace_n_rename(; tgt_folder, src_projname, tgt_projname, src_scriptname, tgt_scriptname, ignorecase)

    return nothing 
end



# function makeproj(tgt_folder, tgt_projname, tgt_scriptname; 
#     ignorecase=true, authors::Vector{String}=String[], src_folder=nothing, src_scriptname=nothing, force=false)

#     (; src_folder, src_scriptname, src_projfolder, src_proj_foldername) = getsource(tgt_folder, src_folder, src_scriptname)

#     (;proj_tomldict, src_projname)= proj_toml(src_projfolder, tgt_projname, authors)
#     @assert uppercase(src_proj_foldername) == uppercase(src_projname)

#     copy_proj(src_folder, tgt_folder, src_projname, proj_tomldict; force, tgt_projname)

#     replace_n_rename(; tgt_folder, src_projname, tgt_projname, src_scriptname, tgt_scriptname, ignorecase)

#     return nothing 
# end

