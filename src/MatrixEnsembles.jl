module MatrixEnsembles
using LinearAlgebra
import Base: rand, size
using Random: GLOBAL_RNG, AbstractRNG
using Requires


export rand, size, QIContinuousMatrixDistribution
export curand
abstract type QIContinuousMatrixDistribution; end

rand(c::QIContinuousMatrixDistribution) = rand(GLOBAL_RNG, c)

include("ginibre.jl")
include("circular.jl")
include("wigner.jl")
include("wishart.jl")

function __init__()
    @require CUDA="052768ef-5323-5732-b1bb-66c8b64840ba" begin
        if CUDA.functional()
            const CuArray = CUDA.CuArray
            const CuVector = CUDA.CuVector
            const CuMatrix = CUDA.CuMatrix
            const CuSVD = CUDA.CUSOLVER.CuSVD
            const CuQR = CUDA.CUSOLVER.CuQR

            CUDA.allowscalar(false)
            include("cuda/circular.jl") 
            include("cuda/ginibre.jl")
            include("cuda/wigner.jl")
            include("cuda/wishart.jl")
        end
    end
end
end
