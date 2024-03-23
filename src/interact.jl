
emptyargs() = Pair{Symbol, Any}[]

function prompt_and_parse(pp)
    proceed = true
    color = pp.color
    colorprint(pp.introduction, color)
    colorprint(pp.prompt, color, false)
    answer = readline()
    cli_args = parse_cl_string(answer)
    parse_args!(pp, cli_args)
    ps = args_pairs(pp)
    if get_value(pp, "--help")  
        help(pp)
        proceed = false
        ps = emptyargs() # ignore other ARGS, if --help
    end
    return (;proceed, argpairs = ps)
end

prompt_and_parse(pp::Nothing) = (;proceed=true, argpairs = emptyargs())

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
    return (;proceed, argpairs = ps0)
end

proc_ARGS(pp::Nothing) = prompt_and_parse(pp) 

function full_interact(pp0, pps)
    allargpairs = []
    (;proceed, argpairs) = proc_ARGS(pp0)
    proceed || return nothing
    push!(allargpairs, argpairs)

    while true
        (;proceed, argpairs) = prompt_and_parse(pps.gen_options)
        if proceed
            push!(allargpairs, argpairs)
            break
        end
    end

    @show allargpairs
    commonargs = mergent(allargpairs)

    while proceed
        (;proceed, argpairs) = prompt_and_parse(pps.spec_options)
        specargs = mergent(commonargs, argpairs)
        (;proceed, xlargs) = get_xl()
        (;proceed, argpairs) = prompt_and_parse(pps.next_file)
        ab = mergent((;abort=false,), argpairs)
        proceed &= !ab.abort

    end

    

    proceed && push!(allargpairs, argpairs)
    @show allargpairs


    return nothing
end
