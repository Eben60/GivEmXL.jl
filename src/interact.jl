
emptyargs() = Pair{Symbol, Any}[]

function prompt_and_parse(pp)
    add_argument!(pp, "-a", "--abort", 
            type=Bool, 
            default=false, 
            description="Abort switch.",
            ) 
    color = pp.color
    ps = nothing

    while true
        colorprint(pp.introduction, color)
        colorprint(pp.prompt, color, false)
        answer = readline()
        cli_args = parse_cl_string(answer)
        parse_args!(pp, cli_args)
        ps = args_pairs(pp)
        get_value(pp, "--abort") && return (;abort=true, argpairs=emptyargs())
        if get_value(pp, "--help")  
            help(pp)
            ps = emptyargs() # ignore other ARGS, if --help
        else
            break
        end
    end
    return (;abort=false, argpairs = ps)
end

prompt_and_parse(pp::Nothing) = (;abort=false, argpairs = emptyargs())

function proc_ARGS(pp0)
    proceed = true
    if !isnothing(pp0)
        parse_args!(pp0.parser)
        if get_value(pp0, "--help")  
            help(pp0)
            proceed = false
        end
        ps0 = args_pairs(pp0)
    else
        ps0 = emptyargs()
    end
    return (;abort = !proceed, argpairs = ps0)
end

proc_ARGS(pp::Nothing) = prompt_and_parse(pp) 

function full_interact(pp0, pps)
    allargpairs = []
    (;abort, argpairs) = proc_ARGS(pp0)
    abort && return nothing
    push!(allargpairs, argpairs)

    (;abort, argpairs) = prompt_and_parse(pps.gen_options)
    abort && return nothing 
    push!(allargpairs, argpairs)

    @show allargpairs
    commonargs = mergent(allargpairs)

    while !abort
        (;abort, argpairs) = prompt_and_parse(pps.spec_options)
        abort && return nothing 
        specargs = mergent(commonargs, argpairs)
        (;abort, xlargs) = get_xl()
        abort && return nothing 

        (; df_setup, df_exp) = xlargs

        isnothing(df_setup) || (setup = mergent(specargs, df_setup))

        @show xlargs
        (;abort, argpairs) = prompt_and_parse(pps.next_file)
        abort && return nothing 
    end


    # proceed && push!(allargpairs, argpairs)
    # @show allargpairs


    return nothing
end
