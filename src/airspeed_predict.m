clear;
close all;

%% user input
load('../data/test.mat')

load('../models/BEM.mat')
coeff_Va_BEM = coeff_Va;
load('../models/WT.mat')
coeff_Va_WT = coeff_Va;
load('../models/flight_AS.mat')
coeff_Va_AS = coeff_Va;
load('../models/flight_GPS.mat')
coeff_Va_GPS = coeff_Va;

intercept_Va = 0;

load('../models/BEM_j.mat')
coeff_J_BEM = coeff_J;
intercept_J_BEM = intercept_J;
load('../models/WT_j.mat')
coeff_J_WT = coeff_J;
intercept_J_WT = intercept_J;
load('../models/flight_AS_j.mat')
coeff_J_AS = coeff_J;
intercept_J_AS = intercept_J;
load('../models/flight_GPS_j.mat')
coeff_J_GPS = coeff_J;
intercept_J_GPS = intercept_J;

alpha_crit = 25*pi/180;

D = 8*0.0254;
motor_arm = 0.24;
efficiency = 0.874;

%%
airspeed = data.airspeed;
rpm = data.rpm;
voltage = data.voltage;
current = data.current;
gyrop = data.gyrop;
Vdown = data.Vdown;
Vnorth = data.Vnorth;
Veast = data.Veast;
theta = data.theta;
t = data.t;
fs = data.fs;

power = voltage.*current*efficiency;
airspeed = airspeed - gyrop*motor_arm;
velocity = sqrt(Vnorth.^2 + Veast.^2 + Vdown.^2);

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed = filtfilt(b,a,airspeed);
rpm = filtfilt(b,a,rpm);
power = filtfilt(b,a,power);
Vdown = filtfilt(b,a,Vdown);
velocity = filtfilt(b,a,velocity);
theta = filtfilt(b,a,theta);

%%
J = airspeed./((rpm/60)*D);
Cp = power./(1.225*D^5*(rpm/60).^3);
gamma = asin(-Vdown./velocity);
theta = theta + pi/2;
alpha = theta - gamma;

%% derivatives
rpm_dot = [zeros(1,1); diff(rpm,1)]*fs;

%%
datarange = ones(length(t),1);
datarange = datarange & alpha<alpha_crit;

%% Predict
[X_Va, names_Va] = model_structure_Pw(power, rpm*pi/30, [], 'bem_reduced');
[X_J, names_J] = model_structure_Cp(Cp, 'bem_reduced');

Va_hat_BEM = X_Va(datarange,:) * coeff_Va_BEM + intercept_Va;
Va_hat_WT = X_Va(datarange,:) * coeff_Va_WT + intercept_Va;
Va_hat_AS = X_Va(datarange,:) * coeff_Va_AS + intercept_Va;
Va_hat_GPS = X_Va(datarange,:) * coeff_Va_GPS + intercept_Va;

J_hat_BEM = X_J(datarange,:) * coeff_J_BEM + intercept_J_BEM;
Va_hat2_BEM = J_hat_BEM .* (rpm(datarange)/60) * D;
J_hat_WT = X_J(datarange,:) * coeff_J_WT + intercept_J_WT;
Va_hat2_WT = J_hat_WT .* (rpm(datarange)/60) * D;
J_hat_AS = X_J(datarange,:) * coeff_J_AS + intercept_J_AS;
Va_hat2_AS = J_hat_AS .* (rpm(datarange)/60) * D;
J_hat_GPS = X_J(datarange,:) * coeff_J_GPS + intercept_J_GPS;
Va_hat2_GPS = J_hat_GPS .* (rpm(datarange)/60) * D;

disp("****************** BEM metrics ******************");
dispModelInfo(airspeed(datarange), Va_hat_BEM, names_Va, coeff_Va_BEM, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_BEM, names_J, coeff_J_BEM, intercept_J_BEM);
disp("****************** WT metrics ******************");
dispModelInfo(airspeed(datarange), Va_hat_WT, names_Va, coeff_Va_WT, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_WT, names_J, coeff_J_WT, intercept_J_WT);
disp("****************** AS metrics ******************");
dispModelInfo(airspeed(datarange), Va_hat_AS, names_Va, coeff_Va_AS, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_AS, names_J, coeff_J_AS, intercept_J_AS);
disp("****************** GPS metrics ******************");
dispModelInfo(airspeed(datarange), Va_hat_GPS, names_Va, coeff_Va_GPS, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_GPS, names_J, coeff_J_GPS, intercept_J_GPS);

%% visualization

% airspeed
figure('Name', 'Va predict', 'Position', [200, 400, 600, 400]);

ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2, 'TickLabelInterpreter', 'latex');

hold on;
plot(t(datarange), airspeed(datarange), '-', 'Color', 'k', 'LineWidth', 2);
scatter(t(1:20:end), airspeed(1:20:end), 5, 'k', 'filled');
plot(t(datarange), Va_hat_BEM, '-', 'Color', [178,171,210]/255, 'LineWidth', 0.6);
plot(t(datarange), Va_hat_GPS, '-', 'Color', [230,97,1]/255, 'LineWidth', 0.6);
hold off;

xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');

h = legend('Pitot', 'No estimate', ...
           '$V_a(P,\omega)$ - BEM', ...
           '$V_a(P,\omega)$ - GPS');
set(h, 'Interpreter', 'latex', 'FontSize', 14);
legend boxoff;
box on;
axis padded;

% AoA and J
figure('Name', 'Angle of Attack and Advance Ratio', 'Position', [900, 400, 600, 400]);

ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2, 'TickLabelInterpreter', 'latex');

yyaxis left
plot(t, rad2deg(alpha), 'Color', [0, 0, 0]/255, 'LineWidth', 1);
ylabel('$\alpha$ [deg]', 'FontSize', 14, 'Interpreter', 'latex');
ax.YColor = [0.15 0.15 0.15];

yyaxis right
hold on
plot(t, J, 'Color', [230, 97, 1]/255, 'LineWidth', 1);
hold off;
ylabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ax.YColor = [230, 97, 1]/255;

ax.XColor = [0.15 0.15 0.15];
xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');

h = legend('$\alpha$', '$J$');
set(h, 'Interpreter', 'latex', 'FontSize', 14);
legend boxoff;
box on;
axis padded;