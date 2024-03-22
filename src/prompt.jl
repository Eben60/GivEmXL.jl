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


function testpp()
    pp = PromptedParser(; parser = ArgumentParser(description="CLI prompt test example.", add_help=true), 
                        color = "magenta", 
                        introduction = "introducing line",
                        prompt = "please> ")

    add_argument!(pp, "-f", "--fileformat"; 
            type=String, 
            required=false, 
            # default="",
            description="Accepted file format (e.g. DOC, TXT, RTF)",
            )
    
    add_example!(pp, "$(pp.prompt) --fileformat ODT")
    add_example!(pp, "$(pp.prompt) --help")
    return pp
end

function prompt_and_parse(pp::PromptedParser)
    color = pp.color
    colorprint(pp.introduction, color)
    colorprint(pp.prompt, color, false)
    answer = readline()
    cli_args = parse_cl_string(answer)
    parse_args!(pp, cli_args)
    ps = args_pairs(pp)
    return ps
end

pp = testpp()
prompt_and_parse(pp)