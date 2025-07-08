clear;
close all;

%% user input
load('../data/input/training.mat')
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
Vnorth = data.Vnorth;
Veast = data.Veast;
Vdown = data.Vdown;
psi = data.psi;
theta = data.theta;
t = data.t;
fs = data.fs;

power = voltage.*current*efficiency;

airspeed_uav = airspeed;
airspeed = airspeed - gyrop*motor_arm;

velocity = sqrt(Vnorth.^2 + Veast.^2 + Vdown.^2);

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed = filtfilt(b,a,airspeed);
airspeed_uav = filtfilt(b,a,airspeed_uav);
rpm = filtfilt(b,a,rpm);
power = filtfilt(b,a,power);
psi = filtfilt(b,a,psi);
Vnorth = filtfilt(b,a,Vnorth);
Veast = filtfilt(b,a,Veast);
Vdown = filtfilt(b,a,Vdown);
velocity = filtfilt(b,a,velocity);
theta = filtfilt(b,a,theta);

%%
J = airspeed./((rpm/60)*D);
Cp = power./(1.225*D^5*(rpm/60).^3);
gamma = asin(-Vdown./velocity);
theta = theta + pi/2;
alpha = theta - gamma;

%% calibrate airspeed
[calib_test, VWN, VWE] = calib_airspeed(airspeed_uav, Vnorth, Veast, gamma, psi, t);

%% derivatives
rpm_dot = [zeros(1,1); diff(rpm,1)]*fs;

%%
datarange = ones(length(t),1);
datarange = datarange & alpha<alpha_crit;

%% Fit
Y1 = Vnorth - VWN; 
Y2 = Veast - VWE;

[X_Va, names] = model_structure_Pw(power, rpm*pi/30, [], 'bem_reduced');
% scale input matrix to avoid matrix rank numerical issues; p^2/w^5 feature produces very small numbers
X_Va(:,2) = X_Va(:,2)*10^11;
% form the total input matrix
X1 = X_Va .* cos(gamma) .* cos(psi);
X2 = X_Va .* cos(gamma) .* sin(psi);
% fit
B_Va = [X1(datarange,:); X2(datarange,:)] \ [Y1(datarange); Y2(datarange)];
% scale back
B_Va(2) = B_Va(2)*10^11;
X_Va(:,2) = X_Va(:,2)*10^-11;

X1 = X_Va .* cos(gamma) .* cos(psi);
X2 = X_Va .* cos(gamma) .* sin(psi);

[X_J, names_J] = model_structure_Cp(Cp, 'bem_reduced');
X_J = [ones(length(X_J),1) X_J]; % add intercept
% form input matrix
X1_J = (X_J .* (rpm/60) * D) .* cos(gamma) .* cos(psi);
X2_J = (X_J .* (rpm/60) * D) .* cos(gamma) .* sin(psi);
% fit
B_J = [X1_J(datarange,:); X2_J(datarange,:)] \ [Y1(datarange); Y2(datarange)];

intercept_Va = 0;
coeff_Va = B_Va;
intercept_J = B_J(1);
coeff_J = B_J(2:3);

%% Predict
Va_north_hat = X1(datarange,:) * coeff_Va + intercept_Va;
Va_east_hat = X2(datarange,:) * coeff_Va + intercept_Va;
Va_hat = sqrt(Va_north_hat.^2 + Va_east_hat.^2);

Va_north_hat_J = X1_J(datarange,:) * B_J;
Va_east_hat_J = X2_J(datarange,:) * B_J;
Va_hat2 = sqrt(Va_north_hat_J.^2 + Va_east_hat_J.^2);

dispModelInfo(airspeed(datarange), Va_hat, names, coeff_Va, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% visualization

% plot AoA
figure('Name','Angle of Attack');
plot(t(datarange), rad2deg(alpha(datarange)), 'k', LineWidth=1.2);
xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$\alpha$ [deg]', 'FontSize', 14, 'Interpreter', 'latex');

% plot fit
figure('Name','Airspeed fit using Ground Speed data');

hold on;
scatter(t(datarange), airspeed(datarange), 9, 'k', 'filled');
scatter(t(datarange), Va_hat, 3, 'r', 'filled');
scatter(t(datarange), Va_hat2, 3, 'g', 'filled');
hold off;

xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');

h = legend('Ground Truth', ...
           '$\beta_1 \omega + \beta_2 \frac{P^2}{\omega^5}$', ...
           '$\frac{\omega}{2\pi}(\alpha_0 + \alpha_1 C_P + \alpha_2 C_P^4)$');

set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)

%% save models
% names_Va = {'w', 'p^2*w^-5'};
% save('../models/flight_GPS.mat', 'names_Va', 'coeff_Va');
% save('../models/flight_GPS_j.mat', 'names_J', 'coeff_J', 'intercept_J');