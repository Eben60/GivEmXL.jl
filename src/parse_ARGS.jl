

to_nt(d) = NamedTuple([(Symbol(k) => v) for (k,v) in d if !isnothing(v)])