function data_list = data_selector(ac_datalist,v_a_select)
    fields = fieldnames(ac_datalist);
    data_list = struct();
    for j = 1:length(fields)
        ac_data = ac_datalist.(fields{j});
        
        %Interpolating Block
        radio_control = interp1(ac_data.ROTORCRAFT_RADIO_CONTROL.timestamp, double(ac_data.ROTORCRAFT_RADIO_CONTROL.mode), ac_data.SERIAL_ACT_T4_IN.timestamp);
        airspeed_data = double(interp1(ac_data.AIR_DATA.timestamp,double(ac_data.AIR_DATA.airspeed), ac_data.SERIAL_ACT_T4_IN.timestamp));
        airspeed_data(isnan(airspeed_data),1) = 0;
        rpm_data = double(ac_data.SERIAL_ACT_T4_IN.motor_1_rpm);
        power_data = double(ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int.*ac_data.SERIAL_ACT_T4_IN.motor_1_current_int)./10000;
        dshot_data = double(ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd);
        rollrate_data = interp1(ac_data.IMU_GYRO_SCALED.timestamp,double(ac_data.IMU_GYRO_SCALED.gp_alt), ac_data.SERIAL_ACT_T4_IN.timestamp);
        rollrate_data(isnan(rollrate_data),1) = 0;
        vert_speed = interp1(ac_data.ROTORCRAFT_FP.timestamp, double(ac_data.ROTORCRAFT_FP.vup_alt) ,ac_data.SERIAL_ACT_T4_IN.timestamp);
        vert_speed(isnan(vert_speed),1) = 0;
        timestamp = ac_data.SERIAL_ACT_T4_IN.timestamp;

        %Filtering Block
        fs = 500 ; 
        dt = 1/fs;
        filter_freq = 20;
        [b, a] = butter(2,filter_freq/(fs/2));
        
        rpmfilt_data= filtfilt(b, a,rpm_data);
        powerfilt_data = filtfilt(b, a,power_data);
        airspeedfilt_data = filtfilt(b, a,airspeed_data);
        dshotfilt_data = filtfilt(b, a,dshot_data);
        rollratefilt_data = filtfilt(b, a, rollrate_data);
        vertfilt_speed = filtfilt(b,a,vert_speed);
        
        
        %RPM Rate Block
        rpmrate_data = zeros(length(rpm_data),1);
        dshotrate_data = zeros(length(dshot_data),1);
        
        for i = 1:length(rpm_data)-1
            rpmrate_data(i+1) = (rpmfilt_data(i+1)-rpmfilt_data(i))/ dt; %Order one numerical deferentiation (improve later)
            dshotrate_data(i+1) = (dshotfilt_data(i+1) - dshotfilt_data(i)) /dt;
        end
    
        % Velocity Correction #1 Due to motor offset and roll rate 
        
        V_correction = -0.2.*deg2rad(rollratefilt_data);
        airspeedfilt_data = airspeedfilt_data + V_correction;

        % Velocity Correction #2 Due to the airspeed offset at the starting
        %condition.)
        
        %land_cond = find(vertfilt_speed<0.1 & rpmfilt_data<50 & vertfilt_speed> -0.1);
        %V_correction2 = mean(airspeedfilt_data(land_cond));

        %airspeedfilt_data = airspeedfilt_data - V_correction2;

        %Cutting Block
        %gps_data = interp1(ac_data.GPS_INT.timestamp,double(ac_data.GPS_INT.airspeed),ac_data.SERIAL_ACT_T4_IN.timestamp);
        index = (find(radio_control>-1 & airspeedfilt_data>v_a_select & rpmfilt_data>1000)-1);
       
        data.airspeed = airspeedfilt_data(index);
        data.rpm = rpmfilt_data(index);
        data.power = powerfilt_data(index);
        data.rpmrate = rpmrate_data(index);
        data.timestamp = timestamp(index);
        data.dshot = dshot_data(index);
        data.dshotrate = dshotrate_data(index);
        data_list.(fields{j}) = data;

    end