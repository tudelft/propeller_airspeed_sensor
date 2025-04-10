% load dataset to be tested first

%% load estimated model
load('models/WT.mat');

%% 
% 144
tranges = [253 333];

%%
fs = 500;

datarange = [];
for i = 1:size(tranges,1)
    trange = tranges(i,:);

    datarange_start = find(ac_data.SERIAL_ACT_T4_IN.timestamp > trange(1), 1, 'first') - 1;
    datarange_end = find(ac_data.SERIAL_ACT_T4_IN.timestamp > trange(2), 1, 'first') - 1;

    datarange = [datarange datarange_start:datarange_end];
end

%%
t = ac_data.SERIAL_ACT_T4_IN.timestamp;

% gyro = [ac_data.IMU_GYRO_SCALED.gp_alt ac_data.IMU_GYRO_SCALED.gq_alt ac_data.IMU_GYRO_SCALED.gr_alt]/180*pi;
% gyro = interp1(ac_data.IMU_GYRO_SCALED.timestamp, gyro, t, "linear", "extrap");

airspeed = interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.airspeed, t, "linear", "extrap");
% angle = interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.angle, t, "linear", "extrap");
rpm = double([ac_data.SERIAL_ACT_T4_IN.motor_1_rpm, ac_data.SERIAL_ACT_T4_IN.motor_2_rpm]);
current = double([ac_data.SERIAL_ACT_T4_IN.motor_1_current_int, ac_data.SERIAL_ACT_T4_IN.motor_2_current_int])/100;
voltage = double([ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int, ac_data.SERIAL_ACT_T4_IN.motor_2_voltage_int])/100;
dshot = double([ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd, ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd]);
power = voltage.*current;

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed_filt = filtfilt(b,a,airspeed);
rpm_filt = filtfilt(b,a,rpm);
current_filt = filtfilt(b,a,current);
voltage_filt = filtfilt(b,a,voltage);
power_filt = filtfilt(b,a,power);
dshot_filt = filtfilt(b,a,dshot);
% gyro_filt = filtfilt(b,a,gyro);

%% derivatives
rpm_filtd = [zeros(1,2); diff(rpm_filt,1)]*fs;
dshot_filtd = [zeros(1,2); diff(dshot_filt,1)]*fs;

%%
% datarange2 = airspeed>=9 & power(:,1)>=30 & angle<1 & rpm_filtd(:,1)<1000 & rpm_filtd(:,1)>-1000 & rpm(:,1)<10000;
datarange2 = airspeed>=9 & power(:,1)>=30 & rpm_filtd(:,1)<1000 & rpm_filtd(:,1)>-1000 & rpm(:,1)<10000;

datarange = datarange & datarange2;

%%
input = [power_filt(datarange,1) rpm_filt(datarange,1) , ...
         power_filt(datarange,1).^2 rpm_filt(datarange,1).^2];

airspeed_pred = predict(mdl, input);

hold on; grid on; zoom on;
plot(t(datarange), airspeed(datarange), '.', MarkerEdgeColor='b', DisplayName="Real data");
plot(t(datarange), airspeed_pred, '.', MarkerEdgeColor='r', DisplayName="Interpolated data");
xlabel('t[sec]');
ylabel('[m/s]');
title('Airspeed');
legend('show');
hold off;