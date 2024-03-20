function parse_cl_string(s) 
    v = split(s)
end

argpair(s, args) = Symbol(s) => get_value(args, s)