function [corr_factor, VWN, VWE] = calib_airspeed(airspeed, Vnorth, Veast, gamma, psi, t)

    b = [Vnorth;
         Veast];
    A = [airspeed.*cos(gamma).*cos(psi) ones(length(t),1)  zeros(length(t),1);
         airspeed.*cos(gamma).*sin(psi) zeros(length(t),1) ones(length(t),1)];
    
    x = A \ b;
    
    corr_factor = x(1);
    VWN = x(2);
    VWE = x(3);
end