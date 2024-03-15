function repl(; basedir=nothing)
    # imgtype = nothing
    # while true
    #     println("Select the plots output format")
    #     println("Enter s for SVG, p for PDF, or just press ENTER for PNG")
    #     t = readline(stdin)
    #     t = t |> strip |> uppercase
    #     if isempty(t)
    #         imgtype="png"
    #     elseif t == "S"
    #         imgtype="svg"
    #     elseif t == "P"
    #         imgtype = "pdf"
    #     else
    #         println("sorry, cannot understand your input")
    #     end
    #     !isnothing(imgtype) && break
    # end
    if isnothing(basedir) && @has_preference("basedir")
        basedir = @load_preference("basedir")
        !isdir(basedir) && (basedir=nothing)
    end
    isnothing(basedir) && (basedir = homedir())

    rslt = nothing
    while true
        global rslt
        fname = pick_file(basedir, filterlist = "xlsx")
        isempty(fname) && break # user cancelled
        basedir = splitdir(fname)[1]
        try
            rslt = process_data(fname)
            @set_preferences!("basedir" => basedir)
        catch ex
            println("Something went wrong: $ex")
        end
        println("Completed processing $fname")
    end
    return rslt
end