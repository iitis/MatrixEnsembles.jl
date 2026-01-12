module MatrixEnsembles
using LinearAlgebra
using KernelAbstractions
import Base: rand, size
using Random: GLOBAL_RNG, AbstractRNG

export rand, size, QIContinuousMatrixDistribution
export curand

abstract type QIContinuousMatrixDistribution; end

rand(c::QIContinuousMatrixDistribution) = rand(GLOBAL_RNG, c)

"""
    curand(dist)

Generate a random sample from `dist` using the default CUDA RNG.
Requires `CUDA.jl` to be loaded.
"""
function curand end

include("ginibre.jl")
include("circular.jl")
include("wigner.jl")
include("wishart.jl")

end
