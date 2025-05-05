function airspeedfilt_data = gps_offset_correction(ac_data,airspeedfilt_data,index,timestamp);
    index = index(length(index)*0.5:length(index)*0.6);
    quat = double([ac_data.AHRS_REF_QUAT.body_qi ac_data.AHRS_REF_QUAT.body_qx ac_data.AHRS_REF_QUAT.body_qy ac_data.AHRS_REF_QUAT.body_qz]);
    %refquat = double([ac_data.AHRS_REF_QUAT.ref_qi ac_data.AHRS_REF_QUAT.ref_qx ac_data.AHRS_REF_QUAT.ref_qy ac_data.AHRS_REF_QUAT.ref_qz]);
    [refquat_t,irefquat_t,~] = unique(ac_data.AHRS_REF_QUAT.timestamp);
    quat = quat(irefquat_t,:);
    %refquat = refquat(irefquat_t,:);
    [psi, ~, ~] = quat2angle(quat,'ZXY');
    
    %airspeed = interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.airspeed, t, "linear", "extrap");
    groundspeed = [interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.vnorth_alt, timestamp), ...
               interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.veast_alt, timestamp)];
    psi = interp1(ac_data.AHRS_REF_QUAT.timestamp, psi, timestamp);
    
    

    b = [groundspeed(index,1);
     groundspeed(index,2)];
    A = [airspeedfilt_data(index).*cos(psi(index)) ones(length(timestamp(index)),1) zeros(length(timestamp(index)),1); airspeedfilt_data(index).*sin(psi(index)) zeros(length(timestamp(index)),1) ...
        ones(length(timestamp(index)),1)];

    x = A \ b;
    
    airspeedfilt_data = airspeedfilt_data * x(1); 
    fprintf("Airspeed after second correction %5.3f \n",airspeedfilt_data(300)*x(1))

end