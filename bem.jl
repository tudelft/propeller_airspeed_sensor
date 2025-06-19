using CCBlade
using Plots
using DataFrames
using MAT

inspectdr()

rho = 1.225
Rtip = 8/2 * 2.54 * 0.01
Rhub = 0.10*Rtip
B = 2

rotor = Rotor(Rhub, Rtip, B)

# r/R    c/R     angle (deg)
propgeom = [
    0.15  0.19278  38.65178;
    0.20  0.22050  43.34022;
    0.25  0.24318  38.38890;
    0.30  0.25956  35.07434;
    0.35  0.27600  32.34590;
    0.40  0.25226  29.68000;
    0.45  0.27972  27.67236;
    0.50  0.28224  25.43364;
    0.55  0.28350  23.39632;
    0.60  0.27720  22.46882;
    0.65  0.25578  20.89472;
    0.70  0.24822  20.10516;
    0.75  0.23436  18.62000;
    0.80  0.21168  17.24064;
    0.85  0.19656  15.71556;
    0.90  0.16380  14.89148;
    0.95  0.12852  11.88684;
    1.00  0.08694  8.97820;
]

r = propgeom[:, 1] * Rtip
chord = propgeom[:, 2] * Rtip
theta = propgeom[:, 3] * pi/180

af = AlphaAF("airfoils/naca4412.dat")

sections = Section.(r, chord, theta, Ref(af))

# define the range of the input to the BEM algorithm (rpm,Va)
nRPM = 100
nVa = 100
Va = range(0.01, 35, length=nVa)
rpm = range(0, 10000, length=nRPM)
P = zeros(nVa,nRPM)
P2 = zeros(nVa,nRPM)

# run the algorithm for the various operating points 
for j = 1:nVa
    for i = 1:nRPM
        local Omega = rpm[i]*pi/30
        local op = simple_op.(Va[j], Omega, r, rho)
        outputs = solve.(Ref(rotor), sections, op)
        T, Q = thrusttorque(rotor, sections, outputs)
        eff, CT, CQ = nondim(T, Q, Va[j], Omega, rho, rotor, "propeller")
        P[j,i] = 2π*CQ * rho * (rpm[i]/60)^3 * (2Rtip)^5
        P2[j,i] = Q*Omega
        if j == 1 && i == 90
            print(CQ)
            print(rpm[i])
        end
    end
end
P[P .< 0] .= NaN

# plot P vs Va for selected RPM
plot(Va,P[:,50],  label="5000", linewidth=2, xlabel="Airspeed (m/s)", ylabel="Power (W)", show=true)
plot!(Va,P[:,60], label="6000", linewidth=2)
plot!(Va,P[:,70], label="7000", linewidth=2)
plot!(Va,P[:,80], label="8000", linewidth=2)

# restructure the data in a (rpm,P,Va) format, using dataframes
X = zeros(nRPM*nVa,2)
Y = zeros(nRPM*nVa,1)
for i = 1:nRPM
    for j = 1:nVa
        X[(i-1)*nVa + j,1] = rpm[i]
        X[(i-1)*nVa + j,2] = P[j,i]
        Y[(i-1)*nVa + j] = Va[j]
    end
end
data = DataFrame(rpm=vec(X[:,1]), power=vec(X[:,2]), va = vec(Y))

# P as a function of t
BEM_t_dict = Dict("rpm" => data.rpm, "power" => data.power, "airspeed" => data.va)
matwrite("BEM.mat", BEM_t_dict)

# # P as a function of Va and w
# BEM_dict = Dict(
#     "w" => collect(rpm),
#     "Va" => collect(Va),
#     "P" => P
# )
# matwrite("BEM.mat", BEM_dict)