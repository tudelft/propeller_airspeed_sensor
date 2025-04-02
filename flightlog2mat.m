% first load the flight log using paparazzi_log_parsing repo
% and then run this code to save a reduced copy of the mat file

data = struct();

data.SERIAL_ACT_T4_IN.timestamp = ac_data.SERIAL_ACT_T4_IN.timestamp;
data.SERIAL_ACT_T4_IN.motor_1_rpm = ac_data.SERIAL_ACT_T4_IN.motor_1_rpm; 
data.SERIAL_ACT_T4_IN.motor_2_rpm = ac_data.SERIAL_ACT_T4_IN.motor_2_rpm; 
data.AIR_DATA.airspeed = ac_data.AIR_DATA.airspeed;
data.SERIAL_ACT_T4_IN.motor_1_current_int = ac_data.SERIAL_ACT_T4_IN.motor_1_current_int;
data.SERIAL_ACT_T4_IN.motor_2_current_int = ac_data.SERIAL_ACT_T4_IN.motor_2_current_int;
data.SERIAL_ACT_T4_IN.motor_1_voltage_int = ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int;
data.SERIAL_ACT_T4_IN.motor_2_voltage_int = ac_data.SERIAL_ACT_T4_IN.motor_2_voltage_int;

ac_data = data; % when loaded it will appear as "ac_data" for consistency
save(fullfile("reduced_flight_logs", log_nbr), 'ac_data');

clear data;