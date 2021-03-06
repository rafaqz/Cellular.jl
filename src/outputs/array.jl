"""
    ArrayOutput <: Output

    ArrayOutput(init; tspan::AbstractRange, [aux, mask, padval]) 

A simple output that stores each step of the simulation in a vector of arrays.

# Arguments

- `init`: initialisation `Array` or `NamedTuple` of `Array`

# Keywords

- `tspan`: `AbstractRange` timespan for the simulation
- `aux`: NamedTuple of arbitrary input data. Use `get(data, Aux(:key), I...)` 
    to access from a `Rule` in a type-stable way.
- `mask`: `BitArray` for defining cells that will/will not be run.
- `padval`: padding value for grids with neighborhood rules. The default is `zero(eltype(init))`.
"""
mutable struct ArrayOutput{T,F<:AbstractVector{T},E} <: Output{T,F} 
    frames::F
    running::Bool
    extent::E
end
function ArrayOutput(; frames, running, extent, kw...)
    append!(frames, _zerogrids(init(extent), length(tspan(extent))-1))
    ArrayOutput(frames, running, extent)
end

"""
    ResultOutput <: Output

    ResultOutput(init; tspan::AbstractRange, kw...) 

A simple output that only stores the final result, not intermediate frames.

# Arguments

- `init`: initialisation `Array` or `NamedTuple` of `Array`

# Keywords

- `tspan`: `AbstractRange` timespan for the simulation
- `aux`: NamedTuple of arbitrary input data. Use `get(data, Aux(:key), I...)` 
    to access from a `Rule` in a type-stable way.
- `mask`: `BitArray` for defining cells that will/will not be run.
- `padval`: padding value for grids with neighborhood rules. The default is `zero(eltype(init))`.
"""
mutable struct ResultOutput{T,F<:AbstractVector{T},E} <: Output{T,F} 
    frames::F
    running::Bool
    extent::E
end
ResultOutput(; frames, running, extent, kw...) = ResultOutput(frames, running, extent)

isstored(o::ResultOutput) = false
storeframe!(o::ResultOutput, data::AbstractSimData) = nothing

function finalise!(o::ResultOutput, data::AbstractSimData) 
    _storeframe!(eltype(o), o, data)
end
