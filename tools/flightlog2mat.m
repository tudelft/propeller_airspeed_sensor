% load the ac_data first

%% make the new struct
data = struct();

% SERIAL_ACT_T4_IN
data.SERIAL_ACT_T4_IN.timestamp = ac_data.SERIAL_ACT_T4_IN.timestamp;
data.SERIAL_ACT_T4_IN.motor_1_rpm = ac_data.SERIAL_ACT_T4_IN.motor_1_rpm; 
data.SERIAL_ACT_T4_IN.motor_1_current_int = ac_data.SERIAL_ACT_T4_IN.motor_1_current_int;
data.SERIAL_ACT_T4_IN.motor_1_voltage_int = ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int;

% SERIAL_ACT_T4_OUT
data.SERIAL_ACT_T4_OUT.timestamp = ac_data.SERIAL_ACT_T4_OUT.timestamp;
data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd = ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd;

% AIR_DATA
data.AIR_DATA.timestamp = ac_data.AIR_DATA.timestamp;
data.AIR_DATA.airspeed = ac_data.AIR_DATA.airspeed;

% IMU_GYRO_SCALED
data.IMU_GYRO_SCALED.timestamp = ac_data.IMU_GYRO_SCALED.timestamp;
data.IMU_GYRO_SCALED.gp_alt = ac_data.IMU_GYRO_SCALED.gp_alt;
data.IMU_GYRO_SCALED.gq_alt = ac_data.IMU_GYRO_SCALED.gq_alt;
data.IMU_GYRO_SCALED.gr_alt = ac_data.IMU_GYRO_SCALED.gr_alt;

% ROTORCRAFT_FP
data.ROTORCRAFT_FP.timestamp = ac_data.ROTORCRAFT_FP.timestamp;
data.ROTORCRAFT_FP.vnorth_alt = ac_data.ROTORCRAFT_FP.vnorth_alt;
data.ROTORCRAFT_FP.veast_alt = ac_data.ROTORCRAFT_FP.veast_alt;

% EULER
quat = double([ac_data.AHRS_REF_QUAT.body_qi ac_data.AHRS_REF_QUAT.body_qx ac_data.AHRS_REF_QUAT.body_qy ac_data.AHRS_REF_QUAT.body_qz]);
[~,iquat_t,~] = unique(ac_data.AHRS_REF_QUAT.timestamp);
quat = quat(iquat_t,:);
[psi, phi, theta] = quat2angle(quat,'ZXY');

data.EULER.timestamp = ac_data.AHRS_REF_QUAT.timestamp;
data.EULER.phi = (180/pi)*phi;
data.EULER.theta = (180/pi)*theta;
data.EULER.psi = (180/pi)*psi;

%% save as "ac_data" for consistency
ac_data = data;
save(fullfile("post_data/flight", log_nbr), 'ac_data');