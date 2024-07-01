pp0 = let
    pp = initparser(ArgumentParser;
        description="Command line options parser", 
        add_help=true, 
        color = promptcolor, 
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
    description="If false, exceptions will be caught and stacktrace saved to file. If true, program run interrupted, and stacktrace printed. Default is false", 
    ) 
        
    add_example!(pp, " $batchfilename --plotformat NONE")
    add_example!(pp, " $batchfilename -e")
    add_example!(pp, " $batchfilename --help")
    pp
end


gen_options = nothing

spec_options = nothing

next_file = let
    pp = initparser(InteractiveArgumentParser;
        description="Prompt for next file", 
        add_help=true, 
        color = promptcolor, 
        introduction="press <ENTER> to process next file, of -a<ENTER> to abort ",
        prompt=prompt,
        )
    
    add_example!(pp, "$(pp.prompt) --abort")
    add_example!(pp, "$(pp.prompt) -a")
    add_example!(pp, "$(pp.prompt) --help")
    pp
end

exelfile_prompt = let
    pp = initparser(InteractiveArgumentParser;
        description="Prompt for Excel file", 
        add_help=true, 
        color = promptcolor, 
        introduction="press <ENTER>, then select Excel file.",
        prompt=prompt,
        )
    pp
end

pps = (;gen_options, spec_options, exelfile_prompt, next_file)

