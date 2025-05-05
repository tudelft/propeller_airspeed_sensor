function gps_offset_correction(ac_data,airspeedfilt_data,index,timestamp);
    
    quat = double([ac_data.AHRS_REF_QUAT.body_qi ac_data.AHRS_REF_QUAT.body_qx ac_data.AHRS_REF_QUAT.body_qy ac_data.AHRS_REF_QUAT.body_qz]);
    %refquat = double([ac_data.AHRS_REF_QUAT.ref_qi ac_data.AHRS_REF_QUAT.ref_qx ac_data.AHRS_REF_QUAT.ref_qy ac_data.AHRS_REF_QUAT.ref_qz]);
    [refquat_t,irefquat_t,~] = unique(ac_data.AHRS_REF_QUAT.timestamp);
    quat = quat(irefquat_t,:);
    %refquat = refquat(irefquat_t,:);
    [psi, ~, ~] = quat2angle(quat,'ZXY');

    %airspeed = interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.airspeed, t, "linear", "extrap");
    groundspeed = [interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.vnorth_alt, t, "linear", "extrap"), ...
               interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.veast_alt, t, "linear", "extrap")];
    psi = interp1(ac_data.AHRS_REF_QUAT.timestamp, psi, t, "linear", "extrap");


    b = [groundspeed(datarange,1);
     groundspeed(datarange,2)];
    A = [airspeedfilt_data(index).*cos(psi(index)) ones(length(timestamp(index)),1) zeros(length(t(index)),1);
     airspeed(index).*sin(psi(datarange)) zeros(length(timstamp(index)),1) ones(length(timestamp(index)),1)];

    x = A \ b;

    figure("Name","Airspeed calib correction"); hold on;
    plot(t(datarange), airspeed(datarange), 'DisplayName', 'Measured Airspeed');
    plot(t(datarange), x(1)* airspeed(datarange), 'DisplayName', 'Corrected Airspeed');
    legend show;

    figure("Name","psi");
    plot(t(datarange),psi(datarange));
    

end