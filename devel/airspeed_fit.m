clear;
close all;

%% user input
WT = false;

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/144-145-148.mat')
% tranges = [250 326]; % 144
% tranges = [918 1051; 1051.1 1163; 1363 1486];
% tranges = [250 326; 497 517; 918 1051; 1051.1 1163; 1363 1486];

load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0254-0257.mat')
% tranges = [0 1600]; % whole (0254 - 0257)
tranges = [0 970]; % 0254
% tranges = [0 859; 870 879; 889 938; 967 970]; % 0254
% tranges = [1430 1443; 1554 1566; 1585 1598]; % 0257
% tranges = [840 980; 1430 1443; 1554 1566; 1585 1598];

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0418.mat')
% tranges = [545 600; 650 670; 693 725];

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/wt/whole_1motor_3angles.mat')
% tranges = [0 1316]; % angle == 0
% WT = true;

LASSO_EXPLORE = false;
idx_Va = 72;
idx_J = 58;

%%
t = ac_data.AIR_DATA.timestamp;
fs = 500;
t = (t(1):1/fs:t(end))';

%%
airspeed = interp1(ac_data.AIR_DATA.timestamp, ...
                               ac_data.AIR_DATA.airspeed, t, 'linear', 'extrap');
rpm = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
              double(ac_data.SERIAL_ACT_T4_IN.motor_1_rpm), t, 'linear', 'extrap' );
current = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
                  double(ac_data.SERIAL_ACT_T4_IN.motor_1_current_int)/100, t, 'linear', 'extrap');
voltage = interp1(double(ac_data.SERIAL_ACT_T4_IN.timestamp), ...
                  double(ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int)/100, t, 'linear', 'extrap');
power = voltage.*current;

if ~WT
    gyro_p = interp1(ac_data.IMU_GYRO_SCALED.timestamp, ...
                     ac_data.IMU_GYRO_SCALED.gp_alt, t, 'linear', 'extrap')*pi/180;
    airspeed = airspeed - gyro_p*0.24;
    theta = interp1(ac_data.EULER.timestamp, ac_data.EULER.theta, t, 'linear', 'extrap');
    psi = interp1(ac_data.EULER.timestamp, ac_data.EULER.psi, t, 'linear', 'extrap');
    psi = psi*pi/180;
    Vnorth = interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.vnorth_alt, t, 'linear', 'extrap');
    Veast = interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.veast_alt, t, 'linear', 'extrap');
else
    angle = interp1(ac_data.AIR_DATA.timestamp, ...
                    ac_data.AIR_DATA.angle, t, 'linear', 'extrap');
end

%% calibrate airspeed
[airspeed, VWN, VWE] = calib_airspeed(airspeed, Vnorth, Veast, psi, t, tranges);

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

if ~WT
    datarange = datarange & airspeed>5 & power>10 & (theta<-70 & theta>-110); 
else
    datarange = datarange & power>40 & rpm_dot<200 & rpm_dot>-200;
end
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

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% visualization

% reindex t to make compact plots
% t_compact = t(datarange);
t_compact = 1:length(t(datarange));

figure('Name','Va fit');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
scatter(t_compact, airspeed(datarange), 9, 'k', 'filled');
scatter(t_compact, Va_hat, 3, 'r', 'filled');
% scatter(t_compact, Va_hat2, 4, 'g', 'filled');
hold off;
xlabel('Sample index', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 16, 'Interpreter', 'latex');
h = legend('Airspeed', 'Fitted airspeed with $V_a(P,\omega)$');
% h = legend('Airspeed', 'Fitted airspeed with $V_a(P,\omega)$', 'Fitted airspeed with $V_a(C_P)$');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 10)
legend boxoff;
box on;
axis padded

%% save the model
% save('/home/ntouev/MATLAB/propeller_airspeed_sensor/models/144.mat', ...
%      'names_Va', 'names_J', ...
%      'coeff_Va', 'coeff_J', ...
%      'intercept_Va', 'intercept_J');