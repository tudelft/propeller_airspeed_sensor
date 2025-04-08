% first load the flight log using paparazzi_log_parsing repo

%%
tranges = [128 980];

datarange = [];
for i = 1:size(tranges,1)
    trange = tranges(i,:);

    datarange_start = find(ac_data.SERIAL_ACT_T4_IN.timestamp > trange(1), 1, 'first') - 1;
    datarange_end = find(ac_data.SERIAL_ACT_T4_IN.timestamp > trange(2), 1, 'first') - 1;
        
    datarange = [datarange datarange_start:datarange_end];
end

%%
trangeV0000 = [128 500];
datarange_start = find(ac_data.AIR_DATA.timestamp > trangeV0000(1), 1, 'first') - 1;
datarange_end = find(ac_data.AIR_DATA.timestamp > trangeV0000(2), 1, 'first') - 1;      
datarangeV0000 = datarange_start:datarange_end;

trangeV0493 = [500 650];
datarange_start = find(ac_data.AIR_DATA.timestamp > trangeV0493(1), 1, 'first') - 1;
datarange_end = find(ac_data.AIR_DATA.timestamp > trangeV0493(2), 1, 'first') - 1;      
datarangeV0493 = datarange_start:datarange_end;

trangeV0993 = [650 840];
datarange_start = find(ac_data.AIR_DATA.timestamp > trangeV0993(1), 1, 'first') - 1;
datarange_end = find(ac_data.AIR_DATA.timestamp > trangeV0993(2), 1, 'first') - 1;      
datarangeV0993 = datarange_start:datarange_end;

trangeV1500 = [840 980];
datarange_start = find(ac_data.AIR_DATA.timestamp > trangeV1500(1), 1, 'first') - 1;
datarange_end = find(ac_data.AIR_DATA.timestamp > trangeV1500(2), 1, 'first') - 1;      
datarangeV1500 = datarange_start:datarange_end;

%%
data = struct();

% SERIAL_ACT_T4_IN
data.SERIAL_ACT_T4_IN.timestamp = ac_data.SERIAL_ACT_T4_IN.timestamp(datarange);
data.SERIAL_ACT_T4_IN.motor_1_rpm = ac_data.SERIAL_ACT_T4_IN.motor_1_rpm(datarange); 
data.SERIAL_ACT_T4_IN.motor_2_rpm = ac_data.SERIAL_ACT_T4_IN.motor_2_rpm(datarange); 
data.SERIAL_ACT_T4_IN.motor_1_current_int = ac_data.SERIAL_ACT_T4_IN.motor_1_current_int(datarange);
data.SERIAL_ACT_T4_IN.motor_2_current_int = ac_data.SERIAL_ACT_T4_IN.motor_2_current_int(datarange);
data.SERIAL_ACT_T4_IN.motor_1_voltage_int = ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int(datarange);
data.SERIAL_ACT_T4_IN.motor_2_voltage_int = ac_data.SERIAL_ACT_T4_IN.motor_2_voltage_int(datarange);

% SERIAL_ACT_T4_OUT
data.SERIAL_ACT_T4_OUT.timestamp = ac_data.SERIAL_ACT_T4_OUT.timestamp(datarange);
data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd = ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd(datarange);
data.SERIAL_ACT_T4_OUT.motor_2_dshot_cmd = ac_data.SERIAL_ACT_T4_OUT.motor_2_dshot_cmd(datarange); 

% AIR_DATA
data.AIR_DATA.timestamp = ac_data.AIR_DATA.timestamp;
data.AIR_DATA.airspeed = 0*ac_data.AIR_DATA.airspeed;
data.AIR_DATA.airspeed(datarangeV0493) = 4.93*ones(length(datarangeV0493),1);
data.AIR_DATA.airspeed(datarangeV0993) = 9.93*ones(length(datarangeV0993),1);
data.AIR_DATA.airspeed(datarangeV1500) = 15.00*ones(length(datarangeV1500),1);
data.AIR_DATA.angle = 0*ones(length(ac_data.AIR_DATA.timestamp),1);

%% save as "ac_data" for consistency
ac_data = data;
save(fullfile("reduced_flight_logs", log_nbr), 'ac_data');
% save(fullfile("reduced_flight_logs", log_nbr), 'ac_data', '-v7.3');

clear data;