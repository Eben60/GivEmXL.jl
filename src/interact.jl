"""
    parse_cl_string(s::AbstractString) →  ::String[]

Wrapper around Base.shell_split

Function `parse_cl_string` is public, not exported.
"""
function parse_cl_string(s) 
    return string.(Base.shell_split(s))
end

emptyargs() = Pair{Symbol, Any}[]

"""
    prompt_and_parse(pp::Nothing) = (;abort=false, argpairs = emptyargs())
    prompt_and_parse(pp::ArgumentParser) → (;abort, argpairs)

Prints a prompt, read and parses the input from the user. See the flow diagram in the documentation for details.

# Arguments
- `pp::Union{Nothing, ArgumentParser}`: ArgumentParser for command line arguments.

# Returned NamedTuple
- `abort::Bool`
- `argpairs`: Vector of pairs `argname::Symbol => argvalue::Any`

Function `prompt_and_parse` is public, not exported.
"""
function prompt_and_parse(pp)
    interactive = pp isa InteractiveArgumentParser
    add_argument!(pp, "-a", "--abort", 
            type=Bool, 
            default=false, 
            description="Abort switch.",
            ) 
    color = getcolor(pp)
    ps = nothing

    while true
        colorprint(pp.introduction, color)
        colorprint(pp.prompt, color, false)
        answer = readline()
        cli_args = parse_cl_string(answer)
        r = parse_args!(pp; cli_args)
        if r isa Exception
            colorprint(r.msg, color)
            help(pp)
            interactive || return (;abort=true, argpairs = emptyargs())
            continue
        end

        ps = args_pairs(pp)
        get_value(pp, "--abort") && return (;abort=true, argpairs=emptyargs())
        if get_value(pp, "--help")  
            help(pp)
            set_value!(pp, "--help", false)
            ps = emptyargs() # ignore other ARGS, if --help
        else
            break
        end
    end
    return (;abort=false, argpairs = ps)
end

prompt_and_parse(pp::Nothing) = (;abort=false, argpairs = emptyargs())


"""
    proc_ARGS(pp0::Nothing) = (;abort=false, argpairs = emptyargs())
    proc_ARGS(pp0::ArgumentParser) → (;abort, argpairs)

Reads and parses the arguments provided to the script from the command line. See the flow diagram in the documentation for details.

# Arguments
- `pp0::Union{Nothing, ArgumentParser}`: ArgumentParser for command line arguments.

# Returned NamedTuple
- `abort::Bool`
- `argpairs`: Vector of pairs `argname::Symbol => argvalue::Any`

Function `proc_ARGS` is public, not exported.
"""
function proc_ARGS(pp0)
    proceed = true
    if !isnothing(pp0)
        p = parse_args!(pp0)
        exc = p isa Exception
        if exc || get_value(pp0, "--help") 
            exc && colorprint("error parsing supplied arguments", pp0)
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


"""
    exper_paramsets(userargs, df_exp, df_setup) → Vector{NamedTuple}

Merges `userargs` with the parameter in `df_setup` and in each row of `df_exp`
   
# Arguments
- `userargs`: Arguments (e.g. as NamedTuple) 
- `df_exp::Union{Nothing, DataFrame}`: Experiment (subsets) parameter, as read from an excel file.
- `df_setup::Union{Nothing, DataFrame}`: Experiment setup parameter, as read from an excel file. 

Function `exper_paramsets` is exported.
"""
function exper_paramsets(userargs, df_exp=nothing, df_setup=nothing)
    if isnothing(df_exp) & isnothing(df_setup)
        p_sets = [(;)]
    elseif isnothing(df_exp)
        p_sets = [merge_params(nothing, df_setup, nothing).nt]
    else
        p_sets = [merge_params(df_exp, df_setup, row).nt for row in 1:nrow(df_exp)]
    end

    p_sets = merge.(Ref(userargs), p_sets)
    return p_sets
end

"""
    complete_interact(pp0, pps, proc_data_fn::Function; kwargs...) → nothing
    complete_interact(pp0, pps, proc_data_fns::Tuple; kwargs...) → nothing

This is the top level function for building the interaction with the user. See the flow diagram in the documentation for details.
It calls [`proc_ARGS`](@ref) first, [`prompt_and_parse`](@ref) multiple times, and lets user pick file(s) by a GUI. 
The inputs are merged with the parameter in the excel file, and all that passed to user-provided function(s) to perform the data processing.

# Arguments
- `pp0::Union{Nothing, ArgumentParser}`: ArgumentParser for command line arguments.
- `pps::NamedTuple`: ArgumentParsers for individual dialogs. The corresponding keys are: 
    `[:gen_options, :spec_options, :exelfile_prompt, :datafiles_prompt, :next_file]`. To skip a dialog, skip the key.
- `proc_data_fn(; xlfile, datafiles, paramsets)::Function`: Function to do the actual data processing. It takes these three kwargs.
- `proc_data_fns::Tuple`: Alternatively a tuple of three functions can be provides: 
    For preprocessing, processing a subset, and postprocessing. See also [`proc_data`](@ref)

# Keyword arguments
- `basedir=nothing`: The base directory for the file selection dialogs. If `basedir` not provided, uses the cached value.
- `paramtables = (;setup="params_setup", exper="params_experiment")`: The names of the tables containing the corresponding parameters. 
   Set a table to `nothing` to skip it.
- `getexel=false`: If true, execute excel file selection dialog.
- `getdata=(; dialogtype = :none)`: If `:none`, no data file selection dialog, 
    otherwise the parameter will be passed to the [`get_data`](@ref) function to execute file/directory selection dialog.

Function `complete_interact` is exported.
"""
function complete_interact(pp0, pps, proc_data_fn::Function;
        basedir=nothing, 
        paramtables = (;setup="params_setup", exper="params_experiment"),
        getexel=false,
        getdata=(; dialogtype = :none),
        )

    # getdata = merge((;dialogtype=:none, filterlist="", basedir=nothing), getdata)
    pps0 = merge((;gen_options=nothing, spec_options=nothing, 
        exelfile_prompt=nothing, next_file=nothing,
        datafiles_prompt=nothing,
        ), pps)
    allargpairs = []

    (;abort, argpairs) = proc_ARGS(pp0)
    # @show (;abort, argpairs)
    abort && return nothing
    push!(allargpairs, argpairs)

    (;abort, argpairs) = prompt_and_parse(pps.gen_options)
    abort && return nothing 
    push!(allargpairs, argpairs)

    # @show allargpairs
    commonargs = mergent(allargpairs)

    while true
        pps = _deepcopy(pps0)
        xlfile = datafiles = nothing
        (;abort, argpairs) = prompt_and_parse(pps.spec_options)
        abort && return nothing 
        userargs = mergent(commonargs, argpairs)
        # @show userargs
        if getexel
            (;abort, ) = prompt_and_parse(pps.exelfile_prompt)
            abort && return nothing 
            (abort, xlargs, xlfile) = get_xl(; basedir, paramtables)
            abort && return nothing 

            (; df_setup, df_exp) = xlargs
            paramsets = exper_paramsets(userargs, df_exp, df_setup)
        else
            paramsets = userargs
        end

        if getdata.dialogtype != :none
            (;abort, ) = prompt_and_parse(pps.datafiles_prompt)
            abort && return nothing 
            (;abort, datafiles) = get_data(;getdata...)
            abort && return nothing 
        end
        
        proc_data_fn(; xlfile, datafiles, paramsets)
        (;abort, ) = prompt_and_parse(pps.next_file)
        abort && return nothing 
    end

    return nothing
end

function complete_interact(pp0, pps, proc_data_fns::Tuple;
    basedir=nothing, 
    paramtables = (;setup="params_setup", exper="params_experiment"),
    getexel=false,
    getdata=(; dialogtype = :none),
    )
    preproc, procsubset, postproc = proc_data_fns
    proc_data_fn(; kwargs...) = proc_n_save(preproc, procsubset, postproc; kwargs...)
    return complete_interact(pp0, pps, proc_data_fn; basedir, paramtables, getexel, getdata)
end

_deepcopy(x) = deepcopy(x)
_deepcopy(nt::NamedTuple) = NamedTuple([k => _deepcopy(v) for (k, v) in pairs(nt)])