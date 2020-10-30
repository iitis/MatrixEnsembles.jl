using Test
using CUDA

using Random
using StatsBase
using LinearAlgebra

using MatrixEnsembles

my_tests = []
if CUDA.functional()
    push!(my_tests,
    "cuda/ginibre.jl",
    "cuda/circular.jl",
    "cuda/wigner.jl",
    "cuda/wishart.jl"
    )
end

push!(my_tests,
    "circular.jl", 
    "ginibre.jl",
    "wigner.jl",
    "wishart.jl"
)

for my_test in my_tests
    include(my_test)
end
