export CircularEnsemble,
    COE, CUE, CSE, CircularRealEnsemble, CircularQuaternionEnsemble, HaarIsometry
struct CircularEnsemble{β} <: QIContinuousMatrixDistribution
    d::Int
    g::GinibreEnsemble{2}

    function CircularEnsemble{β}(d::Int) where {β}
        β == 4 && mod(d, 2) == 1 ? throw(ArgumentError("Dim must even")) : ()
        g = GinibreEnsemble{2}(d)
        new(d, g)
    end
end

const COE = CircularEnsemble{1}
const CUE = CircularEnsemble{2}
const CSE = CircularEnsemble{4}

@kernel function identity_kernel!(A)
    I, J = @index(Global, NTuple)
    A[I, J] = I == J ? 1 : 0
end

@kernel function symplectic_kernel!(A)
    I, J = @index(Global, NTuple)
    # Check if we are in the same 2x2 block diagonal
    ki = (I - 1) ÷ 2
    kj = (J - 1) ÷ 2

    if ki == kj
        r = (I - 1) % 2
        c = (J - 1) % 2

        if r == 0 && c == 1
            A[I, J] = -1
        elseif r == 1 && c == 0
            A[I, J] = 1
        else
            A[I, J] = 0
        end
    else
        A[I, J] = 0
    end
end

function _qr_fix!(z::AbstractMatrix)
    q, r = qr!(z)
    d = diag(r)
    ph = d ./ abs.(d)
    idim = size(r, 1)

    # Generic densification: Use kernel to create identity
    m = size(q, 1)
    dest = similar(z, m, idim)

    backend = KernelAbstractions.get_backend(dest)
    kernel = identity_kernel!(backend)
    kernel(dest, ndrange = size(dest))

    q_dense = q * dest

    transpose(ph) .* q_dense
end

function _qr_fix(z::AbstractMatrix)
    a = copy(z)
    _qr_fix!(a)
end

function rand(rng::AbstractRNG, c::COE)
    z = rand(rng, c.g)
    u = _qr_fix!(z)
    transpose(u)*u
end

function rand(rng::AbstractRNG, c::CUE)
    z = rand(rng, c.g)
    u = _qr_fix!(z)
    u
end

function rand(rng::AbstractRNG, c::CSE)
    z = rand(rng, c.g)
    u = _qr_fix!(z)

    ur = similar(z, eltype(z), c.d, c.d)
    backend = KernelAbstractions.get_backend(ur)
    kernel = symplectic_kernel!(backend)
    kernel(ur, ndrange = size(ur))

    ur*u*ur'*transpose(u)
end

struct CircularRealEnsemble <: QIContinuousMatrixDistribution
    d::Int
    g::GinibreEnsemble{1}

    function CircularRealEnsemble(d::Int)
        g = GinibreEnsemble{1}(d)
        new(d, g)
    end
end

function rand(rng::AbstractRNG, c::CircularRealEnsemble)
    z = rand(rng, c.g)
    _qr_fix!(z)
end

struct CircularQuaternionEnsemble <: QIContinuousMatrixDistribution
    d::Int
    g::GinibreEnsemble{4}

    function CircularQuaternionEnsemble(d::Int)
        g = GinibreEnsemble{4}(d)
        new(d, g)
    end
end

function rand(rng::AbstractRNG, c::CircularQuaternionEnsemble)
    z = rand(rng, c.g)
    _qr_fix!(z)
end


struct HaarIsometry <: QIContinuousMatrixDistribution
    idim::Int
    odim::Int
    g::GinibreEnsemble{2}

    function HaarIsometry(idim::Int, odim::Int)
        idim <= odim || throw(ArgumentError("idim can't be greater than odim"))
        g = GinibreEnsemble{2}(odim, idim)
        new(idim, odim, g)
    end
end

function rand(rng::AbstractRNG, c::HaarIsometry)
    z = rand(rng, c.g)
    _qr_fix!(z)
end
