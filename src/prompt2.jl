using SimpleArgParse
using GivEmExel

function test_prompt()
    args::ArgumentParser = ArgumentParser(description="CLI prompt test example.", add_help=true)
    add_argument!(args, "-f", "--fileformat"; 
            type=String, 
            required=false, 
            default="",
            description="Accepted file format (e.g. DOC, TXT, RTF)",
            )
    
    add_example!(args, "julia main.jl --fileformat ODT")
    add_example!(args, "julia main.jl --help")

    colorprint("informative text", "cyan")
    colorprint("prompt> ", "cyan", false)
    answer = readline()
    cli_args = parse_cl_string(answer)

    parse_args!(args; cli_args)
    nt = args_pairs(args)
    @show nt
    return nt
end

emptyargs() = Pair{Symbol, Any}[]

pp0 = let
    pp = PromptedParser(; parser = ArgumentParser(description="Command line options parser", add_help=true), 
                        color = "magenta", )

    add_argument!(pp, "-f", "--fileformat"; 
            type=String, 
            required=false, 
            # default="",
            description="Accepted file format (e.g. DOC, TXT, RTF)",
            )
    
    add_example!(pp, "$(pp.prompt) --fileformat ODT")
    add_example!(pp, "$(pp.prompt) --help")
    pp
end


gen_options = let
    pp = PromptedParser(; parser = ArgumentParser(description="Prompt for general options", add_help=true), 
                        color = "cyan", 
                        introduction="please enter desired plot output format",
                        prompt="GivEmExel> ",
                        )

    add_argument!(pp, "-p", "--plotformat"; 
            type=String, 
            required=false, 
            default="PNG",
            description="Accepted plot format (e.g. PNG, SVG, PDF)"
            )
    
    add_example!(pp, "$(pp.prompt) --plotformat SVG")
    add_example!(pp, "$(pp.prompt) - SVG")
    add_example!(pp, "$(pp.prompt) --help")
    pp
end

function prompt_and_parse(pp)
    proceed = true
    if !isnothing(pp)
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
    else
        ps = emptyargs()       
    end
    return (;proceed, argpairs = ps)
end

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

function full_interact(pp0, pps)
    allargpairs = typeof(emptyargs())[]
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
    return nothing
end


# pp = testpp()
# pp0 = makepp0()
pps = (;gen_options)

fi = full_interact(pp0, pps)

# prompt_and_parse(pp)