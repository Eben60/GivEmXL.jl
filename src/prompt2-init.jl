using GivEmExel
using GivEmExel.InternalArgParse

pp0 = let
    pp = initparser(; 
        description="Command line options parser", 
        add_help=true, 
            color = "magenta", 
        )

    add_argument!(pp, "-f", "--fileformat"; 
        type=String, 
        default="DOC",
        description="Accepted file format (e.g. DOC, TXT, RTF)",
        validator=StrValidator(; upper_case=true, patterns=["DOC", "TXT", "RTF", "ODT"]),
        )
    
    add_example!(pp, "$(pp.interactive.prompt) --fileformat ODT")
    add_example!(pp, "$(pp.interactive.prompt) --help")
    pp
end


gen_options = let
    pp = initparser(; 
        description="Prompt for general options", 
        add_help=true, 
            color = "cyan", 
            introduction="please enter desired plot output format (PNG, SVG, PDF, TIF), or <ENTER> for default PNG",
            prompt="GivEmExel> ",   
        )

    add_argument!(pp, "-p", "--plotformat"; 
        type=String, 
        positional=true, 
        default="PNG",
        description="Accepted plot format (e.g. PNG, SVG, PDF, TIF)",
        validator=StrValidator(; upper_case=true, patterns=["PNG", "SVG", "PDF", "TIF"]),
        )
    
    add_example!(pp, "$(pp.interactive.prompt) SVG")
    add_example!(pp, "$(pp.interactive.prompt) <ENTER>")
    add_example!(pp, "$(pp.interactive.prompt) --help")
    pp
end


spec_options = nothing

spec_options = let
    pp = initparser(; 
        description="Prompt for specific options", 
            add_help=true, 
                color = "cyan", 
                introduction="please enter specific options",
                prompt="GivEmExel> ",
            )

    add_argument!(pp, "-b", "--binary", 
        type=Bool, 
        default=false, 
        description="Binary mode switch.",
        )            

    add_example!(pp, "$(pp.interactive.prompt) --binary")
    add_example!(pp, "$(pp.interactive.prompt) -b")
    add_example!(pp, "$(pp.interactive.prompt) --help")
    pp
end

next_file = let
    pp = initparser(; 
        description="Prompt for next file", 
        add_help=true, 
            color = "cyan", 
            introduction="press <ENTER> to process next file, or -a<ENTER> to abort ",
            prompt="GivEmExel> ",
        )
    
    add_example!(pp, "$(pp.interactive.prompt) --abort")
    add_example!(pp, "$(pp.interactive.prompt) -a")
    add_example!(pp, "$(pp.interactive.prompt) --help")
    pp
end

exelfile_prompt = let
    pp = initparser(; 
        description="Prompt for Excel file", 
        add_help=true, 
        interactive=InteractiveUsage(;
            color = "cyan", 
            introduction="press <ENTER>, then select Excel file.",
            prompt="GivEmExel> ",
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