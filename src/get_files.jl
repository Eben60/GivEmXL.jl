"""
    get_xl(; basedir=nothing, paramtables = (;setup="params_setup", exper="params_experiment")) 
        → (;abort, xlargs=rslt, fname)

Calls the function `NativeFileDialog:` `pick_file(datadir; filterlist)` to select an XLSX. 
Passes the file to `read_xl_paramtables` to parse the parameter table(s)
If `datadir` not provided, uses the cached value. Caches the selected directory. 

# Keyword arguments
- `dialogtype`: dialogtype ∈ [:single, :multiple, :folder]
- `datadir`: The base directory for file selection dialog.

# Returned NamedTuple
- `abort::Bool`: Dialog cancelled by user
- `xlargs::NamedTuple`: Tables read into DataFrames - s. [`read_xl_paramtables`](@ref)
- `fname::String`: Selected XLSX file

Function `get_xl` is public, not exported.
"""
function get_xl(; basedir=nothing, paramtables = (;setup="params_setup", exper="params_experiment"))
    if isnothing(basedir) && @has_preference("basedir")
        basedir = @load_preference("basedir")
        !isdir(basedir) && (basedir=nothing)
    end
    isnothing(basedir) && (basedir = homedir())

    fname = pick_file(basedir, filterlist = "xlsx")
    abort = isempty(fname) 
    rslt = nothing
    if !abort
        basedir = splitdir(fname)[1]
        try
            rslt = read_xl_paramtables(fname; paramtables)
            @set_preferences!("basedir" => basedir)
        catch ex
            println("Something went wrong: $ex")
        end
        println("Completed processing $fname")
    end
    return (;abort, xlargs=rslt, fname)
end

"""
    get_data(;dialogtype, filterlist="", datadir=nothing) 
        → (; abort::Bool, datafiles)

Calls the function `NativeFileDialog:` `pick_file(datadir; filterlist)` or `pick_multi_file(datadir; filterlist)`. 
If `datadir` not provided, uses the cached value. Caches the selected directory. Returns file or folder or multiple files.

# Keyword arguments
- `dialogtype`: dialogtype ∈ [:single, :multiple, :folder]
- `datadir`: The base directory for file selection dialog.
- `filterlist`: Will be passed to `pick_file` / `pick_multi_file` function.

# Throws
- On unknown value of `dialogtype`

Function `get_data` is public, not exported.
"""
function get_data(;dialogtype, filterlist="", datadir=nothing)

    if isnothing(datadir) && @has_preference("datadir")
        datadir = @load_preference("datadir")
        !isdir(datadir) && (datadir=nothing)
    end
    isnothing(datadir) && (datadir = homedir())

    if dialogtype == :single
        datafiles = pick_file(datadir; filterlist)
        abort = isempty(datafiles)
        abort || (datadir = splitdir(datafiles)[1])
    elseif dialogtype == :multiple
        datafiles = pick_multi_file(datadir; filterlist)
        abort = isempty(datafiles)
        abort || (datadir = splitdir(datafiles[1])[1])
    elseif dialogtype == :folder
        datafiles = pick_folder(datadir)
        abort = isempty(datafiles)
        abort || (datadir = datafiles)
    else
        error("$dialogtype is not a valid pick file dialog type")
    end

    abort || @set_preferences!("datadir" => datadir)
    
    return (; abort, datafiles)

end