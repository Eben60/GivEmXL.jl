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

function get_data(;dialogtype=:none, filterlist="", datadir=nothing)

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