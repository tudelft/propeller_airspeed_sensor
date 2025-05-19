% clear; 
close all;

%%
t = ac_data.SERIAL_ACT_T4_IN.timestamp;
fs = 500;

datarange = zeros(length(t),1);
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    idx = ac_data.SERIAL_ACT_T4_IN.timestamp >= trange(1) & ...
          ac_data.SERIAL_ACT_T4_IN.timestamp <= trange(2);
    datarange = datarange | idx;
end
datarange = logical(datarange);

%%

% gyro = [ac_data.IMU_GYRO_SCALED.gp_alt ac_data.IMU_GYRO_SCALED.gq_alt ac_data.IMU_GYRO_SCALED.gr_alt]/180*pi;
% gyro = interp1(ac_data.IMU_GYRO_SCALED.timestamp, gyro, t, "linear", "extrap");

airspeed = corr_factor*interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.airspeed, t, "linear", "extrap");
% angle = interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.angle, t, "linear", "extrap");
rpm = double([ac_data.SERIAL_ACT_T4_IN.motor_1_rpm, ac_data.SERIAL_ACT_T4_IN.motor_2_rpm]);
current = double([ac_data.SERIAL_ACT_T4_IN.motor_1_current_int, ac_data.SERIAL_ACT_T4_IN.motor_2_current_int])/100;
voltage = double([ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int, ac_data.SERIAL_ACT_T4_IN.motor_2_voltage_int])/100;
dshot = double([ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd, ac_data.SERIAL_ACT_T4_OUT.motor_1_dshot_cmd]);
power = voltage.*current;

J = airspeed(:,1)./(8*0.0254*rpm(:,1)/60);
Cp = power(:,1)./(1.225*(8*0.0254)^5*(rpm(:,1)/60).^3);
J(isinf(J)) = 0; Cp(isinf(Cp)) = 0;
J(isnan(J)) = 0; Cp(isnan(Cp)) = 0;

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

% gyro_filt = filtfilt(b,a,gyro);
airspeed_filt = filtfilt(b,a,airspeed);
rpm_filt = filtfilt(b,a,rpm);
current_filt = filtfilt(b,a,current);
voltage_filt = filtfilt(b,a,voltage);
power_filt = filtfilt(b,a,power);
dshot_filt = filtfilt(b,a,dshot);

J_filt = filtfilt(b,a,J);
Cp_filt = filtfilt(b,a,Cp);

%% derivatives
rpm_filtd = [zeros(1,2); diff(rpm_filt,1)]*fs;
dshot_filtd = [zeros(1,2); diff(dshot_filt,1)]*fs;

%%
% datarange2 = airspeed>=1 & power(:,1)>=30 & angle<1 & rpm_filtd(:,1)<1000 & rpm_filtd(:,1)>-1000 & rpm(:,1)<10000;
datarange2 = airspeed>=9 & power(:,1)>=30 & rpm_filtd(:,1)<1000 & rpm_filtd(:,1)>-1000 & rpm(:,1)<10000;

datarange = datarange & datarange2;

% %% Fitting for power
% input = [J_filt(datarange) J_filt(datarange).^2];
% output = Cp_filt(datarange);
% 
% mdl_power = fitlm(input, output, "linear", 'Intercept', true);
% 
% fprintf('R^2: %.2f\n', mdl_power.Rsquared.Ordinary);
% fprintf('Coeff: '); fprintf('%.8f ', mdl_power.Coefficients.Estimate); fprintf("\n");
% 
% figure('Name','Cp fit');
% hold on; grid on; zoom on;
% plot(J_filt(datarange), output, '.', MarkerEdgeColor='b', DisplayName="Real");
% plot(J_filt(datarange), mdl_power.Fitted, '.', MarkerEdgeColor='r', DisplayName="Predicted");
% xlabel('J');
% ylabel('Cp');
% title('Cp(J)');
% legend('show');
% hold off;
% 
% %% Invert to find airspeed
% a0 = mdl_power.Coefficients.Estimate(1);
% a1 = mdl_power.Coefficients.Estimate(2);
% a2 = mdl_power.Coefficients.Estimate(3);
% 
% J_pred = (-a1 - sqrt(a1^2 - 4*a2*(a0-Cp_filt(datarange))))/(2*a2);
% Va_pred = J_pred.*(rpm_filt(datarange)/60)*8*0.0254;
% 
% figure('Name','Airspeed from Inversion');
% hold on; grid on; zoom on;
% plot(t(datarange), airspeed_filt(datarange), '.', MarkerEdgeColor='b', DisplayName="Real");
% plot(t(datarange), Va_pred, '.', MarkerEdgeColor='r', DisplayName="Predicted");
% xlabel('t [sec]');
% ylabel('Va [m/s]');
% title('Airspeed');
% legend('show');
% hold off;

%% fitting
input = [power_filt(datarange,1) rpm_filt(datarange,1) , ...
         power_filt(datarange,1).^2 rpm_filt(datarange,1).^2, ...
         power_filt(datarange,1).*rpm_filt(datarange,1), ...
         rpm_filt(datarange,1).*rpm_filtd(datarange,1)];
output = airspeed_filt(datarange);

% mdl = input \ output;
mdl = fitlm(input, output, "linear", 'Intercept', true);

%% plotting
fprintf('R^2: %.2f\n', mdl.Rsquared.Ordinary);
fprintf('Coeff: '); fprintf('%.8f ', mdl.Coefficients.Estimate); fprintf("\n");

figure('Name','Airspeed model fit');
tiledlayout(3, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

ax1 = nexttile([3, 1]);
hold on; grid on; zoom on;
plot(t(datarange), output, '.', MarkerEdgeColor='b', DisplayName="Real data");
plot(t(datarange), mdl.Fitted, '.', MarkerEdgeColor='r', DisplayName="Interpolated data");
xlabel('t[sec]');
ylabel('[m/s]');
title('Airspeed');
legend('show');
hold off;

ax2 = nexttile;
hold on; grid on; zoom on;
plot(t(datarange), rpm_filt(datarange,1), '.', DisplayName="rpm", LineWidth=1.5);
xlabel('t[sec]');
ylabel('[rpm]');
title('rpm');
legend('show');
hold off;

ax3 = nexttile;
hold on; grid on; zoom on;
plot(t(datarange), power_filt(datarange,1), '.', DisplayName="power", LineWidth=1.5);
xlabel('t[sec]');
ylabel('[Watt]');
title('power');
legend('show');
hold off;

ax4 = nexttile;
hold on; grid on; zoom on;
plot(t(datarange), rpm_filtd(datarange,1), '.', DisplayName="rpm dot", LineWidth=1.5);
xlabel('t[sec]');
ylabel('');
title('rpm dot');
legend('show');
hold off;

linkaxes([ax1,ax2,ax3,ax4],'x');

%%
% save('models/WT.mat', 'mdl');