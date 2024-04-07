"""
    AbstractValidator

The supertype for validators.
"""
abstract type AbstractValidator end

# reg_ex= [r"^fo[aoe]$"]))
"""
    StrValidator <: AbstractValidator

String validator. 

# Fields
- `upper_case::Bool = false`: If `true`, input and pattern converted to `uppercase`, 
    except for regex comparison
- `starts_with::Bool = false`: If `true`, validate if one of the words in the `patterns`
    starts with input. Returns the whole matching word.
- `patterns::Vector{Union{AbstractString, Regex}}`
# Examples
```julia-repl
julia> validate("foo", StrValidator(; upper_case=true, patterns=["foo", "bar"]))
(ok = true, v = "FOO")

julia> validate("foo", StrValidator(; patterns=[r"^fo[aoe]\$"]))
(ok = true, v = "foo")

julia> validate("ye", StrValidator(; upper_case=true, starts_with=true, patterns=["yes", "no"]))
(ok = true, v = "YES")
```
"""
@kwdef struct StrValidator <: AbstractValidator
    upper_case::Bool = false
    starts_with::Bool = false
    patterns::Vector{Union{AbstractString, Regex}}
end

function validate(v::AbstractString, vl::StrValidator)
    vl.upper_case && (v = uppercase(v))
    ok = true
    if vl.starts_with
        patterns = vl.patterns  .|> uppercase
        for sw in patterns
            startswith(sw, v) && return (; ok, v=sw) # return full word
        end
    else
        for p in vl.patterns
            if p isa AbstractString
                v == uppercase(p) && return return (; ok, v)
            else
                occursin(p, v) && return return (; ok, v)
            end
        end
    end
    return (; ok=false, v=nothing)
end

@kwdef struct RealValidator <: AbstractValidator
    excl_vals::Vector{Real} = []
    excl_ivls::Vector{Tuple{Real, Real}} = []
    incl_vals::Vector{Real} = []
    incl_ivls::Vector{Tuple{Real, Real}} = []
    RealValidator(excl_vals, excl_ivls, incl_vals, incl_ivls) = all(isempty.([excl_vals, excl_ivls, incl_vals, incl_ivls])) ? 
        error("RealValidator init error: At least one criterium must be non-empty") :
        new(excl_vals, excl_ivls, incl_vals, incl_ivls) 
end

"""
    validate(v::Any, vl::AbstractValidator) → (;ok::Bool, v)

Validate input v against validator vl, and returns named tuple with validation result `ok` 
and (possibly canonicalized) input value `v` on success, or `nothing` on validation failure.
For examples and specific information see documentation for the corresponding Validator,
e.g. `StrValidator` or `RealValidator`.
"""
function validate(v::Real, vl::RealValidator)
    in_interval(v, x) = x[1] <= v <= x[2]

    ok = false
    any([isapprox(v, x) for x in vl.excl_vals]) && return (; ok, v=nothing)
    any(in_interval.(v, vl.excl_ivls)) && return (; ok, v=nothing)

    ok = true
    # if no include criteria specified, anything not excluded considered OK
    (isempty(vl.incl_ivls) && isempty(vl.incl_vals)) && return (; ok, v)  

    any([isapprox(v, x) for x in vl.incl_vals]) && return (; ok, v)
    any(in_interval.(v, vl.incl_ivls)) && return (; ok, v) 
    
    return (; ok=false, v=nothing)
end

validate(v, vl) = error("no method defined for validate($(typeof(v)), $(typeof(vl)))") 

"""
    validate(v::Any, ::Nothing) → (;ok=true, v)
    validate(v::Nothing, ::Any) → (;ok=true, v)

If `nothing` is supplied instead of Validator, validation skipped. The same, if the value `v`
to be validated is `nothing`.
"""
validate(v, ::Nothing) = (; ok=true, v)
validate(v::Nothing, ::Nothing) = (; ok=true, v)
validate(v::Nothing, ::Any) = (; ok=true, v) # nothing is generally a valid value
