clear;
close all;

%% user input
WT = false;
THETA_SELECTION = false; % N/A for wt data
corr_factor = NaN;
p_model_structure = 'bem_reduced_wdot';
Cp_model_structure = 'bem_reduced';
T_COMPACT = false;

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/144.mat')
% tranges = [250 326];

load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0254.mat')
% tranges = [846 970]; % connected interval -> automatic airspeed calibration is possible
tranges = [846 908]; % removed second part
% tranges = [0 908.2; 932.7 970]; corr_factor = 0.85; % short
% tranges = [0 859; 870 879; 889 938; 967 970]; corr_factor = 0.85; % shorter 

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/wt/whole_1motor_3angles.mat')
% tranges = [0 1316]; WT = true; corr_factor = 1; % angle == 0

D = 8*0.0254;

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
if ~WT & isnan(corr_factor) 
    [corr_factor, VWN, VWE] = calib_airspeed(airspeed, Vnorth, Veast, psi, t, tranges);
end
airspeed = corr_factor * airspeed;
fprintf("Airspeed corr_factor = %.2f", corr_factor);

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed = filtfilt(b,a,airspeed);
rpm = filtfilt(b,a,rpm);
power= filtfilt(b,a,power);

%%
J = airspeed./((rpm/60)*D);
Cp = power./(1.225*D^5*(rpm/60).^3);

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
    if THETA_SELECTION
        % probably better to use theta rate here, theta limits are not symmetrical either
        datarange = datarange & airspeed>5 & power>10 & (theta<-70 & theta>-110);
    else
        datarange = datarange & airspeed>5 & power>10;
    end
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
    [X_Va, names_Va] = model_structure_Pw(power, rpm, rpm_dot, p_model_structure);
    [B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'Lambda', 1e-10);
    
    [X_J, names_J] = model_structure_Cp(Cp, Cp_model_structure);    
    [B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'Lambda', 1e-10); 

    intercept_Va = FitInfo_Va.Intercept;
    coeff_Va = B_Va;
    intercept_J = FitInfo_J.Intercept;
    coeff_J = B_J;
end

%% Predict
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;
J_hat = X_J(datarange,:) * coeff_J + intercept_J;
Va_hat2 = J_hat .* (rpm(datarange)/60) * D;

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va, intercept_Va);
% dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% visualization
if T_COMPACT
    % not sure about this statement but seems to be working
    t_compact = 1:length(t(datarange));
else
    t_compact = t(datarange);
end

figure('Name','Va fit');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
% scatter(t_compact, airspeed(datarange), 9, 'k', 'filled');
% scatter(t_compact, Va_hat, 3, 'r', 'filled');
% scatter(t_compact, Va_hat2, 3, 'g', 'filled');
plot(t_compact, airspeed(datarange), 'k-',  LineWidth=2);
plot(t_compact, Va_hat, 'r-',  LineWidth=1.5);
plot(t_compact, Va_hat2, 'g-',  LineWidth=1.5);
hold off;
xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
h = legend('Pitot', ...
           '$\beta_0 + \beta_1 \omega + \beta_2 \frac{P^2}{\omega^5} + \beta_3 \omega \dot{\omega} $', ...
           '$\beta_0 + \beta_1 \omega + \beta_2 \frac{P^2}{\omega^5} + \beta_3 \omega \dot{\omega} $');
% h = legend('Wind tunnel', ...
%            '$\beta_0 + \beta_1 \omega + \beta_2 \frac{P^2}{\omega^5}$', ...
%            '$\alpha_0 + \alpha_1 C_P + \alpha_2 C_P^4$');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
axis padded

%% theta visualization
% %this needs a lot of manual work to display the desired time ranges
% figure('Name','Theta');
% ax = gca;
% set(ax, 'FontSize', 14, 'LineWidth', 1.2);
% set(ax, 'TickLabelInterpreter', 'latex');
% plot(t_compact, theta(datarange), 'k', LineWidth=1.5);
% xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
% ylabel('$\theta$ [deg]', 'FontSize', 14, 'Interpreter', 'latex');
% set(h, 'Interpreter', 'latex');
% set(h, 'FontSize', 11)
% box on;
% axis padded

%% save the model
% save('/home/ntouev/MATLAB/propeller_airspeed_sensor/models/0254.mat', ...
%      'names_Va', 'coeff_Va', 'intercept_Va');

%% random stuff to be removed eventually
% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/144-145-148.mat')
% tranges = [918 1051; 1051.1 1163; 1363 1486];
% tranges = [0 1600];
% tranges = [250 326; 497 517; 918 1051; 1051.1 1163; 1363 1486];

% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0254-0257.mat')
% tranges = [0 1600]; % whole (0254 - 0257)
% tranges = [0 970]; % 0254
% tranges = [0 859; 870 879; 889 938; 967 970]; % 0254 short
% tranges = [1430 1443; 1554 1566; 1585 1598]; % 0257 short
% tranges = [840 980; 1430 1443; 1554 1566; 1585 1598];

% 0418 is not recommended. Flight was far from steady
% load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0418.mat')
% tranges = [0 1600];
% tranges = [545 600; 650 670; 693 725];