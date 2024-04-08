function parse_cl_string(s) 
    return string.(Base.shell_split(s))
end

emptyargs() = Pair{Symbol, Any}[]

function prompt_and_parse(pp; interactive=true)
    add_argument!(pp, "-a", "--abort", 
            type=Bool, 
            default=false, 
            description="Abort switch.",
            ) 
    color = pp.interactive.color
    ps = nothing

    while true
        colorprint(pp.interactive.introduction, color)
        colorprint(pp.interactive.prompt, color, false)
        answer = readline()
        cli_args = parse_cl_string(answer)
        r = parse_args!(pp; cli_args)
        # if r isa Exception
        #     colorprint(r.msg, color)
        #     help(pp)
        #     interactive || return (;abort=true, argpairs = emptyargs())
        #     continue
        # end

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
        parse_args!(pp0)
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

function exper_paramsets(specargs, df_exp, df_setup)
    if isnothing(df_exp) & isnothing(df_setup)
        p_sets = [(;)]
    elseif isnothing(df_exp)
        p_sets = [merge_params(nothing, df_setup, nothing).nt]
    else
        p_sets = [merge_params(df_exp, df_setup, row).nt for row in 1:nrow(df_exp)]
    end

    p_sets = merge.(Ref(specargs), p_sets)
    return p_sets
end

function full_interact(pp0, pps, proc_data_fn;
        basedir=nothing, 
        paramtables = (;setup="params_setup", exper="params_experiment"),
        getexel=false,
        getdata=(; dialogtype = :none),
        )

    # getdata = merge((;dialogtype=:none, filterlist="", basedir=nothing), getdata)
    pps = merge((;gen_options=nothing, spec_options=nothing, 
        exelfile_prompt=nothing, next_file=nothing,
        datafiles_prompt=nothing,
        ), pps)
    allargpairs = []

    (;abort, argpairs) = proc_ARGS(pp0)
    abort && return nothing
    push!(allargpairs, argpairs)

    (;abort, argpairs) = prompt_and_parse(pps.gen_options)
    abort && return nothing 
    push!(allargpairs, argpairs)

    @show allargpairs
    commonargs = mergent(allargpairs)

    while true
        xlfile = datafiles = nothing
        (;abort, argpairs) = prompt_and_parse(pps.spec_options)
        abort && return nothing 
        specargs = mergent(commonargs, argpairs)

        if getexel
            (;abort, ) = prompt_and_parse(pps.exelfile_prompt)
            abort && return nothing 
            (abort, xlargs, xlfile) = get_xl(; basedir, paramtables)
            abort && return nothing 

            (; df_setup, df_exp) = xlargs
            paramsets = exper_paramsets(specargs, df_exp, df_setup)
        else
            paramsets = specargs
        end

        if getdata.dialogtype != :none
            (;abort, ) = prompt_and_parse(pps.datafiles_prompt)
            (;abort, datafiles) = get_data(;getdata...)          
        end
        
        proc_data_fn(; xlfile, datafiles, paramsets)
        
        (;abort, ) = prompt_and_parse(pps.next_file)
        abort && return nothing 
    end


    # proceed && push!(allargpairs, argpairs)
    # @show allargpairs


    return nothing
end
