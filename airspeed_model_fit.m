% clear; 
% close all;

%% 
% load('reduced_flight_logs/144.mat');

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
airspeed = interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.airspeed, t, "linear", "extrap");
rpm = double([ac_data.SERIAL_ACT_T4_IN.motor_1_rpm, ac_data.SERIAL_ACT_T4_IN.motor_2_rpm]);
current = double([ac_data.SERIAL_ACT_T4_IN.motor_1_current_int/100, ac_data.SERIAL_ACT_T4_IN.motor_2_current_int/100]);
voltage = double([ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int/100, ac_data.SERIAL_ACT_T4_IN.motor_2_voltage_int/100]);
power = voltage.*current;

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed_filt = filtfilt(b,a,airspeed);
rpm_filt = filtfilt(b,a,rpm);
current_filt = filtfilt(b,a,current);
voltage_filt = filtfilt(b,a,voltage);
power_filt = filtfilt(b,a,power);

%% derivatives
rpm_filtd = [zeros(1,2); diff(rpm_filt,1)]*fs;

%%
input = [power_filt(datarange,1) rpm_filt(datarange,1) , ...
         power_filt(datarange,1).^2 rpm_filt(datarange,1).^2 , ...
         rpm_filtd(datarange,1)];
output = airspeed_filt(datarange);

% mdl = input \ output;
mdl = fitlm(input, output, "linear", 'Intercept', true);

%%
fprintf('R^2: %.2f\n', mdl.Rsquared.Ordinary);
fprintf('Coeff: '); fprintf('%.8f ', mdl.Coefficients.Estimate); fprintf('\n'); 

figure; hold on; grid on;
plot(t(datarange), output);
% plot(t(datarange), input*mdl);
plot(t(datarange), mdl.Fitted);
xlabel("Time (s)")
ylabel("Airspeed (m/s)")