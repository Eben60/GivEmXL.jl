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
    add_example!(pp, "$(pp.prompt) -p SVG")
    add_example!(pp, "$(pp.prompt) --help")
    pp
end


spec_options = nothing

spec_options = let
    pp = PromptedParser(; parser = ArgumentParser(description="Prompt for specific options", add_help=true), 
                        color = "cyan", 
                        introduction="please enter specific options",
                        prompt="GivEmExel> ",
                        )

    add_argument!(pp, "-b", "--binary", 
            type=Bool, 
            default=false, 
            description="Binary mode switch.",
            )            

    add_example!(pp, "$(pp.prompt) --binary")
    add_example!(pp, "$(pp.prompt) -b")
    add_example!(pp, "$(pp.prompt) --help")
    pp
end

next_file = let
    pp = PromptedParser(; parser = ArgumentParser(description="Prompt for next file", add_help=true), 
                        color = "cyan", 
                        introduction="press <ENTER> to process next file, of -a<ENTER> to abort ",
                        prompt="GivEmExel> ",
                        )         

    add_example!(pp, "$(pp.prompt) --abort")
    add_example!(pp, "$(pp.prompt) -a")
    add_example!(pp, "$(pp.prompt) --help")
    pp
end

exelfile_prompt = let
    pp = PromptedParser(; parser = ArgumentParser(description="Prompt for Excel file", add_help=true), 
                        color = "cyan", 
                        introduction="press <ENTER>, then select Excel file.",
                        prompt="GivEmExel> ",
                        )
    

    pp
end

function demo_fn(; kwargs...)
    println(typeof(kwargs))
    for kw in kwargs
        @show kw
    end
end