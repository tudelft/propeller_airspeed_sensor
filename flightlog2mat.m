% first load the flight log using paparazzi_log_parsing repo

%% V ~ 5
% 0061
tranges = [500 650]; 
% 0062
% tranges = [350 550; 1000 1160];
datarangeV5 = [];
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    datarange_start = find(ac_data.AIR_DATA.timestamp > trange(1), 1, 'first') - 1;
    datarange_end = find(ac_data.AIR_DATA.timestamp > trange(2), 1, 'first') - 1;    
    datarangeV5 = [datarangeV5 datarange_start:datarange_end];
end

%% V ~ 10
% 0061
tranges = [650 840]; 
% 0062
% tranges = [550 670; 1160 1300];
datarangeV10 = [];
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    datarange_start = find(ac_data.AIR_DATA.timestamp > trange(1), 1, 'first') - 1;
    datarange_end = find(ac_data.AIR_DATA.timestamp > trange(2), 1, 'first') - 1;    
    datarangeV10 = [datarangeV10 datarange_start:datarange_end];
end

%% V ~ 15
% 0061
tranges = [840 980]; 
% 0062
% tranges = [670 800; 1300 1420];
datarangeV15 = [];
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    datarange_start = find(ac_data.AIR_DATA.timestamp > trange(1), 1, 'first') - 1;
    datarange_end = find(ac_data.AIR_DATA.timestamp > trange(2), 1, 'first') - 1;    
    datarangeV15 = [datarangeV15 datarange_start:datarange_end];
end

%% V ~ 18
% % 0062
% % tranges = [125 350; 800 1000; 1420 1550];
% datarangeV18 = [];
% for i = 1:size(tranges,1)
%     trange = tranges(i,:);
%     datarange_start = find(ac_data.AIR_DATA.timestamp > trange(1), 1, 'first') - 1;
%     datarange_end = find(ac_data.AIR_DATA.timestamp > trange(2), 1, 'first') - 1;    
%     datarangeV18 = [datarangeV18 datarange_start:datarange_end];
% end

%% A ~ 30
% % 0062
% % tranges = [350 1000];
% datarangeA30 = [];
% for i = 1:size(tranges,1)
%     trange = tranges(i,:);
%     datarange_start = find(ac_data.AIR_DATA.timestamp > trange(1), 1, 'first') - 1;
%     datarange_end = find(ac_data.AIR_DATA.timestamp > trange(2), 1, 'first') - 1;    
%     datarangeA30 = [datarangeA30 datarange_start:datarange_end];
% end

%% A ~ 60
% % 0062
% tranges = [1000 1550];
% datarangeA60 = [];
% for i = 1:size(tranges,1)
%     trange = tranges(i,:);
%     datarange_start = find(ac_data.AIR_DATA.timestamp > trange(1), 1, 'first') - 1;
%     datarange_end = find(ac_data.AIR_DATA.timestamp > trange(2), 1, 'first') - 1;    
%     datarangeA60 = [datarangeA60 datarange_start:datarange_end];
% end

%% make the new struct
data = struct();

% SERIAL_ACT_T4_IN
data.SERIAL_ACT_T4_IN.timestamp = ac_data.SERIAL_ACT_T4_IN.timestamp;
data.SERIAL_ACT_T4_IN.motor_1_rpm = ac_data.SERIAL_ACT_T4_IN.motor_1_rpm; 
data.SERIAL_ACT_T4_IN.motor_2_rpm = ac_data.SERIAL_ACT_T4_IN.motor_2_rpm; 
data.SERIAL_ACT_T4_IN.motor_1_current_int = ac_data.SERIAL_ACT_T4_IN.motor_1_current_int;
data.SERIAL_ACT_T4_IN.motor_2_current_int = ac_data.SERIAL_ACT_T4_IN.motor_2_current_int;
data.SERIAL_ACT_T4_IN.motor_1_voltage_int = ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int;
data.SERIAL_ACT_T4_IN.motor_2_voltage_int = ac_data.SERIAL_ACT_T4_IN.motor_2_voltage_int;

% SERIAL_ACT_T4_OUT
data.SERIAL_ACT_T4_OUT.timestamp = ac_data.SERIAL_ACT_T4_OUT.timestamp;
data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd = ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd;
data.SERIAL_ACT_T4_OUT.motor_2_dshot_cmd = ac_data.SERIAL_ACT_T4_OUT.motor_2_dshot_cmd; 

% AIR_DATA
data.AIR_DATA.timestamp = ac_data.AIR_DATA.timestamp;
data.AIR_DATA.airspeed = 0*ones(length(ac_data.AIR_DATA.timestamp),1);
data.AIR_DATA.airspeed(datarangeV5) = 4.9*ones(length(datarangeV5),1);
data.AIR_DATA.airspeed(datarangeV10) = 9.93*ones(length(datarangeV10),1);
data.AIR_DATA.airspeed(datarangeV15) = 15*ones(length(datarangeV15),1);
% data.AIR_DATA.airspeed(datarangeV18) = 18.02*ones(length(datarangeV18),1);

data.AIR_DATA.angle = 0*ones(length(ac_data.AIR_DATA.timestamp),1);
% data.AIR_DATA.angle(datarangeA30) = 30*ones(length(datarangeA30),1);
% data.AIR_DATA.angle(datarangeA60) = 60*ones(length(datarangeA60),1);

%% plot
figure; 
plot(data.AIR_DATA.timestamp,data.AIR_DATA.airspeed); 
hold; 
plot(data.SERIAL_ACT_T4_IN.timestamp, data.SERIAL_ACT_T4_IN.motor_1_rpm/100);
plot(data.AIR_DATA.timestamp, data.AIR_DATA.angle);

%% save as "ac_data" for consistency
% ac_data = data;
% save(fullfile("post_data", log_nbr), 'ac_data');