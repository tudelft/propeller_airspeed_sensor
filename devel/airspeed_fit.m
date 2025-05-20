clear;
close all;

%% user input
load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/144.mat')
tranges = [250 326]; % whole (144-145-148)
% tranges = [250 326; 497 517; 918 1051; 1051.1 1163; 1363 1486];

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0254-0257.mat')
% tranges = [0 1600]; % whole (0254 - 0257)
% tranges = [0 980]; % 0254
% tranges = [840 980; 1430 1443; 1554 1566; 1585 1598];

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0418.mat')
% tranges = [545 600; 650 670; 693 725];

LASSO_EXPLORE = false;
idx_Va = 72;
idx_J = 58;

%%
corr_factor = 1;
t = ac_data.AIR_DATA.timestamp;
fs = 500;
t = (t(1):1/fs:t(end))';

%%
gyro_p = interp1(ac_data.IMU_GYRO_SCALED.timestamp, ...
                 ac_data.IMU_GYRO_SCALED.gp_alt, t, 'linear', 'extrap')*pi/180;

airspeed = corr_factor*interp1(ac_data.AIR_DATA.timestamp, ...
                               ac_data.AIR_DATA.airspeed, t, 'linear', 'extrap');
airspeed = airspeed - gyro_p*0.24;

rpm = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
              double(ac_data.SERIAL_ACT_T4_IN.motor_1_rpm), t, 'linear', 'extrap' );
current = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
                  double(ac_data.SERIAL_ACT_T4_IN.motor_1_current_int)/100, t, 'linear', 'extrap');
voltage = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
                  double(ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int)/100, t, 'linear', 'extrap');
power = voltage.*current;
theta = interp1(ac_data.EULER.timestamp, ac_data.EULER.theta, t, 'linear', 'extrap');

%% filter with Butterworth before fitting
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed = filtfilt(b,a,airspeed);
rpm = filtfilt(b,a,rpm);
power= filtfilt(b,a,power);

%%
J = airspeed./((rpm/60)*(10*0.0254));
Cp = power./(1.225*(10*0.0254)^5*(rpm/60).^3);

%% derivatives
rpm_dot = [zeros(1,1); diff(rpm,1)]*fs;

%%
datarange = zeros(length(t),1);
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    idx = t >= trange(1) & t <= trange(2);
    datarange = datarange | idx;
end
datarange = logical(datarange);

datarange = datarange & airspeed>5 & power>10 & (theta<-70 & theta>-110); 
datarange = datarange & J>0.3;

%% Fit
if LASSO_EXPLORE
    [X_Va, names_Va] = genFeatures_Pw(power, rpm, -6:1:6, -6:1:6);
    [X_Va, names_Va] = appendFeature(X_Va, rpm.*rpm_dot, names_Va, 'rpm_rpmd');
    [B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'CV', 10);
    % lassoPlot(B_Va, FitInfo_Va, 'PlotType', 'CV'); legend show;
    
    [X_J, names_J] = genFeatures_Cp(Cp, -4:4);
    [B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'CV', 10);
    % lassoPlot(B_J, FitInfo_J, 'PlotType', 'CV'); legend show;

    intercept_Va = FitInfo_Va.Intercept(idx_Va);
    coeff_Va = B_Va(:, idx_Va);
    intercept_J = FitInfo_J.Intercept(idx_J);
    coeff_J = B_J(:, idx_J);
else
    [X_Va, names_Va] = model_structure_Pw(power, rpm, rpm_dot, 'bem_reduced_wdot');
    [B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'Lambda', 1e-10);
    
    [X_J, names_J] = model_structure_Cp(Cp, 'bem_reduced');    
    [B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'Lambda', 1e-10); 

    intercept_Va = FitInfo_Va.Intercept;
    coeff_Va = B_Va;
    intercept_J = FitInfo_J.Intercept;
    coeff_J = B_J;
end

%% Predict
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;
J_hat = X_J(datarange,:) * coeff_J + intercept_J;
Va_hat2 = J_hat .* (rpm(datarange)/60) * (10*0.0254);

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J);

%% visualization
figure;
hold on;
plot(t(datarange), airspeed(datarange), 'k.');
plot(t(datarange), Va_hat, 'r.');
plot(t(datarange), Va_hat2, 'g.');
hold off;
legend('BEM Airspeed', 'Predicted from Va(P,w) model', 'Predicted from J(Cp) model');
xlabel('t [sec]');
ylabel('Airspeed');
title('Airspeed prediction');
grid on;

%% save the model
% save('/home/ntouev/MATLAB/propeller_airspeed_sensor/models/144.mat', ...
%      'names_Va', 'names_J', ...
%      'coeff_Va', 'coeff_J', ...
%      'intercept_Va', 'intercept_J');