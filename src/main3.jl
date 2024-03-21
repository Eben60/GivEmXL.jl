using GivEmExel
using SimpleArgParse


function proc_ARGS()

    args::ArgumentParser = ArgumentParser(description="SimpleArgParse example.", add_help=true)
    add_argument!(args, "-p", "--plotformat"; 
            type=String, 
            required=false, 
            default="PNG", 
            description="Output plot format (any format accepted by Plots.jl)",
            )
    
    add_example!(args, "julia main.jl --plotformat SVG")
    add_example!(args, "julia main.jl --help")
    parse_args!(args)

    # show help if being asked
    get_value(args, "--help")  && help(args, color="cyan")

    return nt_args(args)
end


function main()
    mainkwargs = proc_ARGS()
    @show mainkwargs
    return 0
end

main()