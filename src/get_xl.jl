function get_xl(; basedir=nothing)

    if isnothing(basedir) && @has_preference("basedir")
        basedir = @load_preference("basedir")
        !isdir(basedir) && (basedir=nothing)
    end
    isnothing(basedir) && (basedir = homedir())

    fname = pick_file(basedir, filterlist = "xlsx")
    abort = isempty(fname) 
    rslt = (; )
    if !abort
        basedir = splitdir(fname)[1]
        try
            rslt = process_data(fname)
            @set_preferences!("basedir" => basedir)
        catch ex
            println("Something went wrong: $ex")
        end
        println("Completed processing $fname")
    end
    return (;abort, xlargs=rslt)
end