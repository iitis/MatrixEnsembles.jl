function _qr_fix!(z::CuMatrix)
    q, r = CUDA.qr!(z)
    d = diag(r)
    ph = d ./ abs.(d)
    q = CuMatrix(q)
    idim = size(r, 1)
    for i = 1:idim
        q[:, i] .*= ph[i]
    end
    q[:, 1:idim]
end

function _qr_fix(z::CuMatrix)
    a = copy(z)
    _qr_fix!(a)
end

function curand(c::COE)
    z = curand(c.g)
    u = _qr_fix!(z)
    transpose(u)*u
end

function curand(c::CSE)
    z = curand(c.g)
    u = _qr_fix!(z)
    ur = cat([CuMatrix{Float32}([0 -1; 1 0]) for _=1:c.d÷2]..., dims=[1,2])
    ur*u*ur'*transpose(u)
end

for T in (CUE, CircularRealEnsemble, CircularQuaternionEnsemble, HaarIsometry)
    @eval begin
        function curand(c::$T)
            z = curand(c.g)
            _qr_fix!(z)
        end
    end
end