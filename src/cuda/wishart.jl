function curand(w::WishartEnsemble{β, K}) where {β, K}
    z = curand(w.g)/sqrt(2β * Float32(w.d))
    z*z'
end
