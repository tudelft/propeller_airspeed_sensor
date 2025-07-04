using CCBlade
using DataFrames
using MAT

rho = 1.225
Rtip = 8/2 * 2.54 * 0.01
Rhub = 0.10*Rtip
B = 2

rotor = Rotor(Rhub, Rtip, B)

# r/R    c/R     angle (deg)
propgeom = [
    0.15   0.153   36.463
    0.20   0.175   40.887
    0.25   0.193   36.215
    0.30   0.206   33.089
    0.35   0.219   30.515
    0.40   0.201   28
    0.45   0.222   26.106
    0.50   0.224   23.994
    0.55   0.225   22.072
    0.60   0.220   21.197
    0.65   0.203   19.712
    0.70   0.197   18.986
    0.75   0.186   17.566
    0.80   0.168   16.264
    0.85   0.156   14.826
    0.90   0.130   14.058
    0.95   0.102   11.214
    1.00   0.069   8.47
]

r = propgeom[:, 1] * Rtip
chord = propgeom[:, 2] * Rtip
theta = propgeom[:, 3] * pi/180

af = AlphaAF("BEM/custom.dat")

sections = Section.(r, chord, theta, Ref(af))

# define the range of the input to the BEM algorithm (rpm,Va)
nRPM = 100
nVa = 100
Va = range(0.1, 30, length=nVa)
rpm = range(1000, 10000, length=nRPM)
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
        P2[j,i] = Q*Omega # this should be the same as the above P
    end
end
P = P2
P[P .< 0] .= NaN

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

# save
BEM_t_dict = Dict("rpm" => data.rpm, "power" => data.power, "airspeed" => data.va)
matwrite("BEM.mat", BEM_t_dict)