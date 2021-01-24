Random.seed!(42)

@testset "GinibreEnsemble" begin
    g = GinibreEnsemble{1}(10, 20)
    z = curand(g)
    @test typeof(z) <: CuArray
    @test eltype(z) <: Real
    @test size(z) == (10, 20)
    @test GinibreEnsemble(10, 20) == GinibreEnsemble{2}(10, 20)
    @test GinibreEnsemble(10) == GinibreEnsemble{2}(10, 10)

    @test_throws ArgumentError GinibreEnsemble{4}(11, 21)
    g = GinibreEnsemble{4}(10, 20)
    z = curand(g)
    @test size(z) == (20, 40)
    @test eltype(z) == ComplexF32

@testset "_qr_fix" begin
    a = CUDA.rand(2, 2)
    u1 = MatrixEnsembles._qr_fix(a)
    u2 = MatrixEnsembles._qr_fix!(a)
    @test typeof(u1) <: CuMatrix
    @test norm(u1 - u2) ≈ 0
end
end
