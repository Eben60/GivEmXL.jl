using GivEmExel
using GivEmExel.InternalArgParse

pp0 = let
    pp = ArgumentParser(; 
        description="Command line options parser", 
        add_help=true, 
        interactive=InteractiveUsage(;
            color = "magenta", 
            ),
        )

    add_argument!(pp, "-p", "--plotformat"; 
        type=String, 
        default="PNG",
        description="Accepted file format: PNG (default), PDF, SVG or NONE", 
        validator=StrValidator(; upper_case=true, patterns=["PNG", "SVG", "PDF", "NONE"]),
        )
    add_argument!(pp, "-e", "--throwonerr"; 
    type=Bool, 
    default=false,
    description="If false, exceptions will be cought and stacktrace saved to file. If true, program run interrupted, and stacktrace printed. Default is false", 
    ) 
        
    add_example!(pp, "$(pp.interactive.prompt) $fname --plotformat NONE")
    add_example!(pp, "$(pp.interactive.prompt) $fname -e")
    add_example!(pp, "$(pp.interactive.prompt) $fname --help")
    pp
end


gen_options = nothing

spec_options = nothing

next_file = let
    pp = ArgumentParser(; 
        description="Prompt for next file", 
        add_help=true, 
        interactive=InteractiveUsage(;
            color = "cyan", 
            introduction="press <ENTER> to process next file, of -a<ENTER> to abort ",
            prompt="RcExample> ",
            ), 
        )
    
    add_example!(pp, "$(pp.interactive.prompt) --abort")
    add_example!(pp, "$(pp.interactive.prompt) -a")
    add_example!(pp, "$(pp.interactive.prompt) --help")
    pp
end

exelfile_prompt = let
    pp = ArgumentParser(; 
        description="Prompt for Excel file", 
        add_help=true, 
        interactive=InteractiveUsage(;
            color = "cyan", 
            introduction="press <ENTER>, then select Excel file.",
            prompt="RcExample> ",
            ), 
        )
    pp
end

function demo_fn(; kwargs...)
    println(typeof(kwargs))
    for kw in kwargs
        @show kw
    end
end