function repl(; basedir=homedir())
    # imgtype = nothing
    # while true
    #     println("Select the plots output format")
    #     println("Enter s for SVG, p for PFD, or just press ENTER for PNG")
    #     t = readline(stdin)
    #     t = t |> strip |> uppercase
    #     if isempty(t)
    #         imgtype="png"
    #     elseif t == "S"
    #         imgtype="svg"
    #     elseif t == "p"
    #         imgtype = "pdf"
    #     else
    #         println("sorry, cannot understand your input")
    #     end
    #     !isnothing(imgtype) && break
    # end
    while true
        global rslt
        fname = pick_file(basedir, filterlist = "xlsx")
        isempty(fname) && break # user cancelled
        try
            rslt = process_data(fname)
            # @show rslt
        catch ex
            println("Something went wrong: $ex")
        end
        println("Completed processing $fname")
    end
    return rslt
end