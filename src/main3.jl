using GivEmExel
using SimpleArgParse: ArgumentParser, add_argument, add_example, generate_usage, help, parse_args, 
    get_value, set_value, has_key, get_key, colorize,
    keys


function proc_ARGS()

    args::ArgumentParser = ArgumentParser(description="SimpleArgParse example.", add_help=true)
    args = add_argument(args, "-p", "--plotformat"; 
            type=String, 
            required=false, 
            default="PNG", 
            description="Output plot format (any format accepted by Plots.jl)",
            )
    
    args = add_example(args, "julia main.jl --plotformat SVG")
    args = add_example(args, "julia main.jl --help")
    args = parse_args(args)

    # show help if being asked
    get_value(args, "--help")  && help(args, color="cyan")

    allkeys = keys(args)
    filter!(x -> x != "help", allkeys)
    # @show allkeys

    return [argpair(k, args) for k in allkeys]

end


function main()
    mainkwargs = proc_ARGS()
    for kw in mainkwargs
        @show kw
    end
    return 0
end

main()