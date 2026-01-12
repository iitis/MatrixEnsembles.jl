module MatrixEnsemblesCUDAExt

using MatrixEnsembles
using CUDA
using Random

import MatrixEnsembles: curand

function MatrixEnsembles.curand(d::QIContinuousMatrixDistribution)
    rand(CUDA.default_rng(), d)
end

function __init__()
    CUDA.allowscalar(false)
end

end
