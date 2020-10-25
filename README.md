# MatrixEnsembles.jl

## Sampling random matrices on the GPU

We have introduced an experimental implementation of sampling of random matrices and random quantum objects on the GPU. In order to use this feature, the `CuArrays` package is required. To import `MatrixEnsembles` with GPU support use
```julia
using CuArrays, MatrixEnsembles
```
In order to sample use the `curand` method on a distribuiotn. For instance
```julia
julia> c = CUE(4096)
CircularEnsemble{2}(4096, GinibreEnsemble{2}(4096, 4096))

julia> @time rand(c);
 10.452419 seconds (8.22 k allocations: 2.005 GiB, 2.18% gc time)

julia> @time MatrixEnsembles.curand(c);
  0.459959 seconds (624.79 k allocations: 21.493 MiB)
```
Please report any bugs/problems and feature requests.