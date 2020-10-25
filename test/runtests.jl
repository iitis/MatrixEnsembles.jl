using Test
using Random
using StatsBase
using LinearAlgebra

using MatrixEnsembles

my_tests = ["circular.jl", "ginibre.jl", "wigner.jl", "wishart.jl"]

for my_test in my_tests
    include(my_test)
end
