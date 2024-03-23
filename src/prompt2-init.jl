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