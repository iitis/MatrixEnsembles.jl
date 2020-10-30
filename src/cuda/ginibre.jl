curand(g::GinibreEnsemble{1}) = CuMatrix(CUDA.randn(g.m, g.n))
curand(g::GinibreEnsemble{2}) = CUDA.randn(g.m, g.n)+1im*CUDA.randn(g.m, g.n)

function curand(g::GinibreEnsemble{4})
    q0=CUDA.randn(g.m, g.n)
    q1=CUDA.randn(g.m, g.n)
    q2=CUDA.randn(g.m, g.n)
    q3=CUDA.randn(g.m, g.n)
    [q0+1im*q1 q2+1im*q3; -q2+1im*q3 q0-1im*q1]
end
