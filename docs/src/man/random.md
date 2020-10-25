```@setup MatrixEnsembles
using MatrixEnsembles
using LinearAlgebra
```

# Random quantum objects
In this section we present the implementation of the package
**MatrixEnsembles**. The justification for including these functionalities
in our package is twofold. First, the application of random matrix theory (RMT)
in quantum information is a blooming field of research with a plethora of
interesting
results [[1]](@ref refs_rand), [[2]](@ref refs_rand), [[3]](@ref refs_rand), [[4]](@ref refs_rand),
[[5]](@ref refs_rand), [[6]](@ref refs_rand), [[7]](@ref refs_rand), [[8]](@ref refs_rand), [[9]](@ref refs_rand),
[[10]](@ref refs_rand).
Hence, it is useful to have readily available implementations of known
algorithms of generating random matrices. Secondly, when performing numerical
investigations, we often need ''generic'' inputs. Generating random matrices
with a known distribution is one of the ways to obtain such generic inputs.

## Ginibre matrices

In this section we introduce the Ginibre random matrices
ensemble [[11]](@ref refs_rand). This ensemble is at the core of a vast
majority of algorithms for generating random matrices presented in later
subsections. Let $(G_{ij})_{1 \leq i \leq m, 1 \leq j \leq n}$ be a $m\times n$
table of independent identically distributed (i.i.d.) random variable on
$\mathbb{K}$. The field $\mathbb{K}$ can be either of $\mathbb{R}$, $\mathbb{C}$ or
$\mathbb{Q}$. With each of the fields we associate a Dyson index $\beta$ equal
to $1$, $2$, or $4$ respectively. Let $G_{ij}$ be i.i.d random variables with
the real and imaginary parts sampled independently from the distribution
$\mathcal{N}(0, \frac{1}{\beta})$. Hence, $G \in \mathrm{L}(\mathcal{X}, \mathcal{Y})$, where
matrix $G$ is
\begin{equation}
P(G) \propto \exp(-\mathrm{Tr} G G^\dagger).
\end{equation}
This law is unitarily invariant, meaning that for any unitary matrices $U$ and
$V$, $G$ and $UGV$ are equally distributed. It can be shown that for $\beta=2$
the eigenvalues of $G$ are uniformly distributed over the unit disk on the
complex plane.

In our library the ensemble Ginibre matrices is implemented in the
`GinibreEnsemble{β}` parametric type. The parameter determines the
Dyson index. The following constructors are provided
`GinibreEnsemble{β}(m::Int, n::Int)`, `GinibreEnsemble{β}(m::Int)`, `GinibreEnsemble(m::Int, n::Int)`, `GinibreEnsemble(m::Int)`.
The parameters $n$ and $m$ determine the dimensions of output and input spaces.
The versions with one argument assume $m=n$. When the Dyson index is omitted
it assumed that $\beta=2$. Sampling from these distributions can be performed as
follows
```@repl MatrixEnsembles
g = GinibreEnsemble{2}(2,3)

rand(g)
```
The function `rand` has specialized methods for each possible value
of the Dyson index $\beta$.

## Wishart matrices
Wishart matrices form an ensemble of random positive semidefinite matrices. They
are parametrized by two factors. First is the Dyson index $\beta$ which is equal
to one for real matrices, two for complex matrices and four for symplectic
matrices. The second parameter, $K$, is responsible for the rank of the
matrices. They are sampled as follows
* Choose $\beta$ and $K$.
* Sample a Ginibre matrix $G\in \mathrm{L}(\mathrm{X}, \mathrm{Y})$ with the Dyson index $\beta$
and $\mathrm{dim}(\mathrm{X}) = d$ and $\mathrm{dim}(\mathrm{Y})=Kd$.
* Return $GG^\dagger$.
In **MatrixEnsembles.jl** this is implemented using the type
`WishartEnsemble{β, K}`. We also provide additional constructors for
convenience `WishartEnsemble{β}(d::Int) where β = WishartEnsemble{β, 1}(d)`,
`WishartEnsemble(d::Int) = WishartEnsemble{2}(d)`.

These can be used in the following way
```@repl MatrixEnsembles
w = WishartEnsemble{1,0.2}(5)

z = rand(w)

eigvals(z)

w = WishartEnsemble(3)

z = rand(w)

eigvals(z)
```

## Circular ensembles
Circular ensembles are measures on the space of unitary matrices. There are
three main circular ensembles. Each of this ensembles has an associated Dyson
index $\beta$ [[12]](@ref refs_rand)
* Circular orthogonal ensemble (COE), $\beta=1$.
* Circular unitary ensemble (CUE), $\beta=2$.
* Circular symplectic ensemble (CSE), $\beta=4$.

They can be characterized as follows. The CUE is simply the Haar measure on the
unitary group. Now, if $U$ is an element of CUE then $U^TU$ is an element of
$COE$ and $U_R U$ is an element CSE.
As can be seen the sampling of Haar unitaries is at the core of sampling these
ensembles. Hence, we will focus on them in the remainder of this section.

There are several possible approaches to generating random unitary matrices
according to the Haar measure. One way is to consider known parametrizations of
unitary matrices, such as the Euler [[13]](@ref refs_rand) or
Jarlskog [[14]](@ref refs_rand) ones. Sampling these parameters from
appropriate distributions yields a Haar random unitary. The downside is the long
computation time, especially for large matrices, as this involves a lot of
matrix multiplications. We will not go into this further, we refer the
interested reader to the papers on these parametrizations.

Another approach is to consider a Ginibre matrix $G \in \mathrm{L}(\mathrm{X})$ and its polar
decomposition $G=U P$, where $U \in \mathrm{L}(\mathrm{X})$ is unitary and $P$ is a positive
matrix. The matrix $P$ is unique and given by $\sqrt{G^\dagger G}$. Hence,
assuming $P$ is invertible, we could recover $U$ as
\begin{equation}
U = G (G^\dagger G) ^{-\frac{1}{2}}.
\end{equation}
As this involves the inverse square root of a matrix, this approach can be
potentially numerically unstable.

The optimal approach is to utilize the QR decomposition of $G$, $G=QR$, where $Q
\in \mathrm{L}(\mathrm{X})$ is unitary and $R \in \mathrm{L}(\mathrm{X})$ is upper triangular. This
procedure is unique if $G$ is invertible and we require the diagonal elements of
$R$ to be positive. As typical implementations of the QR algorithm do not
consider this restriction, we must enforce it ourselves. The algorithm is as
follows
* Generate a Ginibre matrix $G \in \mathrm{L}(\mathrm{X})$, $\mathrm{dim}(\mathrm{X}) = d$ with
Dyson index $\beta=2$.
* Perform the QR decomposition obtaining $Q$ and $R$.
* Multiply the $i$\textsuperscript{th} column of $Q$ by $r_{ii}/|r_{ii}|$.

This gives us a Haar distributed random unitary. This procedure can be generalized in
order to obtain a random isometry. The only required changed is the dimension of
$G$. We simply start with $G \in \mathrm{L}(\mathrm{X}, \mathrm{Y})$, where $\dim(\mathrm{X})\geq
\dim(\mathrm{Y})$.

Furthermore, we may introduce two additional circular ensembles corresponding
to the Haar measure on the orthogonal and symplectic groups. These are the
circular real ensemble (CRE) and circular quaternion ensemble (CQE). Their
sampling is similar to sampling from CUE. The only difference is the initial
Dyson index of the Ginibre matrix. This is set to $\beta=1$ for CRE and
$\beta=4$ for CQE.

In `MatrixEnsembles.jl` these distributions can be sampled as
```@repl MatrixEnsembles
c = CircularEnsemble{2}(3)

u = rand(c)

u*u'
```

Sampling from the Haar measure on the orthogonal group can be achieved as
```@repl MatrixEnsembles
c = CircularRealEnsemble(3)

o = rand(c)

o*o'
```
For convenience we provide the following type aliases `const COE = CircularEnsemble{1}`, `const CUE = CircularEnsemble{2}`, `const CSE = CircularEnsemble{4}`.

## [References](@id refs_rand)

[1] B. Collins, I. Nechita, *Random matrix techniques in quantum information theory*, Journal of Mathematical Physics, 2016;57(1):015215.

[2] W. K. Wootters, *Random quantum statesy*, Foundations of Physics, 1990;20(11):1365--1378.

[3] K. Życzkowski, H. J. Sommers, *Induced measures in the space of mixed quantum states*, Journal of Physics A: Mathematical and General, 2001;34(35):7111.

[4] H. J. Sommers, K. Życzkowski, *Statistical properties of random density matrices*, Journal of Physics A: Mathematical and General, 2004;37(35):8457.

[5] Z. Puchała, Ł. Pawela, K. Życzkowski, *Distinguishability of generic quantum states*, Physical Review A, 2016;93(6):062112.

[6] L. Zhang, U. Singh, A. K. Pati, *Average subentropy, coherence and entanglement of random mixed
  quantum states*, Annals of Physics, 2017;377:125--146.

[7] L. Zhang, *Average coherence and its typicality for random mixed quantum states*, Journal of Physics A: Mathematical and Theoretical,
  2017;50(15):155303.

[8] W. Bruzda, V. Cappellini, H. J. Sommers, K. Życzkowski, *Random quantum operations*, Physics Letters A,
  2009;373(3):320--324.

[9] I. Nechita, Z. Puchała, L. Pawela, K. Życzkowski, *Almost all quantum channels are equidistant*, Journal of Mathematical Physics,
  2018;59(5):052201.

[10] L. Zhang, J. Wang, Z. Chen, *Spectral density of mixtures of random density matrices for qubits*, Physics Letters A,
  2018;382(23):1516--1523.

[11] J. Ginibre, *Statistical ensembles of complex, quaternion, and real matrices*, Journal of Mathematical Physics, 1965;6(3):440--449.

[12] M. L. Mehta, *Random matrices. vol. 142.*, Elsevier; 2004.

[13] K. Życzkowski, M. Kuś, *Random unitary matrices*, Journal of Physics A: Mathematical and General, 1994;27(12):4235.

[14] C. Jarlskog, *A recursive parametrization of unitary matrices*, Journal of Mathematical Physics, 2005;46(10):103508.
