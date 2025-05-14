% clear; 
close all;

%% load dataset
load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/144-145-148.mat')

%%
corr_factor = 1;
t = ac_data.AIR_DATA.timestamp;
fs = 200;
t = (t(1):1/fs:t(end))';

%%
airspeed = corr_factor*interp1(ac_data.AIR_DATA.timestamp, ...
                               ac_data.AIR_DATA.airspeed, t, 'linear', 'extrap');
rpm = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
              double(ac_data.SERIAL_ACT_T4_IN.motor_1_rpm), t, 'linear', 'extrap' );
current = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
                  double(ac_data.SERIAL_ACT_T4_IN.motor_1_current_int)/100, t, 'linear', 'extrap');
voltage = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
                  double(ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int)/100, t, 'linear', 'extrap');
power = voltage.*current;
theta = interp1(ac_data.EULER.timestamp, ac_data.EULER.theta, t, 'linear', 'extrap');

%%
J = airspeed./((rpm/60)*(10*0.0254));
Cp = power./(1.225*(10*0.0254)^5*(rpm/60).^3);

%% filter with Butterworth before fitting
% filter_freq = 5;
% [b, a] = butter(2,filter_freq/(fs/2));
% 
% airspeed = filtfilt(b,a,airspeed);
% rpm = filtfilt(b,a,rpm);
% power= filtfilt(b,a,power);
% 
% J(isinf(J)) = 0; Cp(isinf(Cp)) = 0;
% J(isnan(J)) = 0; Cp(isnan(Cp)) = 0;
% J = filtfilt(b,a,J);
% Cp = filtfilt(b,a,Cp);

%%
datarange = airspeed>5 & power>10 & (theta<-70 & theta>-110); 
datarange = datarange & J>0.3;

%% Fit for Va
[X_Va, names_Va] = genFeatures_Pw(power, rpm, -6:1:6, -6:1:6);
[B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'CV', 10, 'PredictorNames', names_Va);
lassoPlot(B_Va, FitInfo_Va, 'PlotType', 'CV'); legend show;

%% Fit for J
[X_J, names_J] = genFeatures_Cp(Cp, -3:3);
[B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'CV', 10, 'PredictorNames', names_J);
lassoPlot(B_J, FitInfo_J, 'PlotType', 'CV'); legend show;

%% 
idx_Va = 65;
idx_J = 65;

intercept_Va = FitInfo_Va.Intercept(idx_Va);
coeff_Va = B_Va(:, idx_Va);
intercept_J = FitInfo_J.Intercept(idx_J);
coeff_J = B_J(:, idx_J);

dispModelInfo(FitInfo_Va, names_Va, coeff_Va, idx_Va);
dispModelInfo(FitInfo_J, names_J, coeff_J, idx_J);

%% Predict timeseries
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;
J_hat = X_J(datarange,:) * coeff_J + intercept_J;

%filter with Butterworth only for visualization
filter_freq = 3;
[b, a] = butter(2,filter_freq/(fs/2));
airspeed = filtfilt(b,a,airspeed);
Va_hat = filtfilt(b,a,Va_hat);
J_hat = filtfilt(b,a,J_hat);

figure;
hold on;
plot(t(datarange), airspeed(datarange), 'k.');
plot(t(datarange), Va_hat, 'r.');
% plot(t(datarange), J_hat .* (rpm(datarange)/60) * (10*0.0254), 'g.');
hold off;
legend('BEM Airspeed', 'Predicted from Va(P,w) model', 'Predicted from J(Cp) model');
xlabel('t [sec]');
ylabel('Airspeed');
title('Lasso Airspeed timeseries prediction');
grid on;

% figure;
% hold on;
% plot(t(datarange), J(datarange), 'k',LineWidth=2.5)
% plot(t(datarange), J_hat, 'g', LineWidth=1.5);
% hold off;