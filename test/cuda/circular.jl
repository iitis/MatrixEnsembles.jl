Random.seed!(42)

@testset verbose=true "CUDA: CircularEnsemble" begin
    @testset verbose=true "CUDA: CUE" begin
        n = 10
        c = CUE(n)
        u = curand(c)
        @test norm(u*u' - I) ≈ 0 atol=1e-5

        n = 100
        c = CUE(n)
        steps = 100
        r = zeros(steps, n)

        for i=1:steps
            u = collect(curand(c))
            r[i, :] = angle.(eigvals(u))
        end
        r = vec(r)
        h = normalize(fit(Histogram, r, weights(ones(size(r))), -π:0.1π:π, closed=:left))
        @test all(isapprox.(h.weights, 1/2π, atol=0.01))
    end

    @testset verbose=true "CUDA: COE" begin
        n = 10
        c = COE(n)
        o = curand(c)
        @test norm(o*o' - I) ≈ 0 atol=1e-5

        n = 100
        c = COE(n)
        steps = 100
        r = zeros(steps, n)
        for i=1:steps
            o = collect(curand(c))
            r[i, :] = angle.(eigvals(o))
        end
        r = vec(r)
        h = normalize(fit(Histogram, r, weights(ones(size(r))), -π:0.1π:π, closed=:left))
        @test all(isapprox.(h.weights, 1/2π, atol=0.1))
    end

    @testset verbose=true "CUDA: CircularRealEnsemble" begin
        c = CircularRealEnsemble(10)
        o = curand(c)
        @test size(o) == (10, 10)
        @test eltype(o) <: Real
    end
end

    @testset verbose=true "CUDA: HaarIsometry" begin
        idim = 2
        odim = 3
        c = HaarIsometry(idim, odim)
        u = curand(c)
        @test size(u) == (odim, idim)
        @test isapprox(norm(u'*u - I), 0, atol=1e-6)
        @test_throws ArgumentError HaarIsometry(odim, idim)

    @testset verbose=true "CUDA: CSE" begin
        n = 10
        c = CSE(n)
        o = curand(c)
        @test norm(o*o' - I) ≈ 0 atol=1e-5
        @test size(o) == (n, n)
    end

    @testset verbose=true "CUDA: Circular quaternion ensemble" begin
        c = CircularQuaternionEnsemble(10)
        u = curand(c)
        @test size(u) == (20, 20)
        @test isapprox(norm(u'*u - I), 0, atol=1e-5)
    end
end