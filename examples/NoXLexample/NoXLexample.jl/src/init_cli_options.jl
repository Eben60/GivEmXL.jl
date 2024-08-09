pp0 = let
    pp = initparser(ArgumentParser;
        description="Command line options parser", 
        add_help=true, 
        color = promptcolor, 
        )

    add_argument!(pp, "-s", "--start"; 
        type=Int, 
        default=1,
        description="First row", 
        )
    
        add_argument!(pp, "-l", "--lastrow"; 
        type=Int, 
        default=typemax(Int),
        description="Last row", 
        )

    add_argument!(pp, "-e", "--throwonerr"; 
        type=Bool, 
        default=false,
        description="If false, exceptions will be caught and stacktrace saved to file. If true, program run interrupted, and stacktrace printed. Default is false", 
        ) 
            
    add_example!(pp, " $batchfilename -s 5 -l 50")
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

exelfile_prompt = nothing

datafiles_prompt = let
    pp = initparser(InteractiveArgumentParser;
        description="Prompt for data file(s)", 
        add_help=true, 
        color = promptcolor, 
        introduction="press <ENTER>, then select CSV file(s).",
        prompt=prompt,
        )
    pp
end

pps = (;gen_options, spec_options, exelfile_prompt, datafiles_prompt, next_file)

