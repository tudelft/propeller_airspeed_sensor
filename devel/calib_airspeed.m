function [calibrated_airspeed, VWN, VWE] = calib_airspeed(airspeed, Vnorth, Veast, psi, t, tranges)

    datarange = zeros(length(t),1);
    for i = 1:size(tranges,1)
        trange = tranges(i,:);
        idx = t >= trange(1) & t <= trange(2);
        datarange = datarange | idx;
    end
    datarange = logical(datarange);

    b = [Vnorth(datarange);
         Veast(datarange)];
    A = [airspeed(datarange).*cos(psi(datarange)) ones(length(t(datarange)),1)  zeros(length(t(datarange)),1);
         airspeed(datarange).*sin(psi(datarange)) zeros(length(t(datarange)),1) ones(length(t(datarange)),1)];
    
    x = A \ b;
    
    calibrated_airspeed = x(1) * airspeed;
    VWN = x(2);
    VWE = x(3);
end