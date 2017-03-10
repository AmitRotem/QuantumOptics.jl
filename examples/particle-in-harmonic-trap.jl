
using QuantumOptics
using PyPlot

# System Parameters
m = 1.
ω = 0.5 # Strength of trapping potential;

# Position Basis
xmin = -5
xmax = 5
Npoints = 100
b_position = PositionBasis(xmin, xmax, Npoints)

# Hamiltonian in real space basis
p = momentumoperator(b_position) # Dense operator
x = positionoperator(b_position) # Sparse operator

H = p^2/2m + 1/2*m*ω^2*full(x^2);

b_momentum = MomentumBasis(b_position);

# Hamiltonian
p = momentumoperator(b_momentum) # Sparse operator
x = positionoperator(b_momentum) # Dense operator

H = full(p^2)/2m + 1/2*m*ω^2*x^2;

# Transforms a state multiplied from the right side from real space
# to momentum space.
T_px = particle.FFTOperator(b_momentum, b_position);

T_xp = dagger(T_px)

x = positionoperator(b_position)
p = momentumoperator(b_momentum)

H_kin = LazyProduct(T_xp, p^2/2m, T_px)
V = ω*x^2
H = LazySum(H_kin, V);

# Initial state
x0 = 1.5
p0 = 0
sigma0 = 0.6
Ψ0 = gaussianstate(b_position, x0, p0, sigma0);

# Time evolution
T = [0:0.1:3;]
tout, Ψt = timeevolution.schroedinger(T, Ψ0, H);

# Plot dynamics of particle density
x_points = particle.samplepoints(b_position)

n = abs(Ψ0.data).^2
V = ω*x_points.^2
C = maximum(V)/maximum(n)

figure(figsize=(6,3))
xlabel(L"x")
ylabel(L"| \Psi(t) |^2")
plot(x_points, (V-3)/C, "k--")

for i=1:length(T)
    Ψ = Ψt[i]
    n = abs(Ψ.data).^2
    plot(x_points, n, "C0", alpha=0.9*(float(i)/length(T))^8+0.1)
end;


