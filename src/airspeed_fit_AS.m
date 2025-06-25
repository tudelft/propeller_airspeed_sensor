clear;
close all;

%% user input
load('../data/training.mat')
Jcrit = 0.20; 

D = 8*0.0254;
motor_arm = 0.24;
efficiency = 0.874;

%%
airspeed = data.airspeed;
rpm = data.rpm;
voltage = data.voltage;
current = data.current;
gyrop = data.gyrop;
t = data.t;
fs = data.fs;

power_input = voltage.*current;
power = power_input*efficiency;
airspeed = airspeed - gyrop*motor_arm;

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed = filtfilt(b,a,airspeed);
rpm = filtfilt(b,a,rpm);
power = filtfilt(b,a,power);
power_input = filtfilt(b,a,power_input);

%%
J = airspeed./((rpm/60)*D);
Cp = power./(1.225*D^5*(rpm/60).^3);
Cp_input = power_input./(1.225*D^5*(rpm/60).^3);

%% derivatives
rpm_dot = [zeros(1,1); diff(rpm,1)]*fs;

%%
datarange = ones(length(t),1);
datarange = datarange & J>Jcrit;

%% Fit
[X_Va, names_Va] = model_structure_Pw(power, rpm*pi/30, [], 'bem_reduced');
% scale input matrix to avoid matrix rank numerical issues; p^2/w^5 feature produces very small numbers
X_Va(:,2) = X_Va(:,2)*10^11;
% fit
B_Va = X_Va(datarange,:) \ airspeed(datarange);
% scale back 
B_Va(2) = B_Va(2)*10^11;
X_Va(:,2) = X_Va(:,2)*10^-11;

[X_J, names_J] = model_structure_Cp(Cp, 'bem_reduced');    
X_J = [ones(length(X_J),1) X_J]; % add the intercept
% fit
B_J = X_J(datarange,:) \ J(datarange);

intercept_Va = 0;
coeff_Va = B_Va;
intercept_J = B_J(1);
coeff_J = B_J(2:3);

%% Predict
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;

J_hat = X_J(datarange,:) * B_J;
Va_hat2 = J_hat .* (rpm(datarange)/60) * D;

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% visualization
figure('Name','Airspeed fit using Airspeed data');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
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
legend boxoff;
box on;
axis padded

%% save models
% save('../models/flight_AS.mat', 'names_Va', 'coeff_Va');
% save('../models/flight_AS_j.mat', 'names_J', 'coeff_J', 'intercept_J');

%% save data for Jcrit calculation
% J_flight = J; Cp_flight = Cp;
% save('../data/Jcrit/flight.mat', 'J_flight', 'Cp_flight');

%% save data for efficiency calculation
% J_flight = J; Cp_flight = Cp_input;
% save('../data/eff/flight.mat', 'J_flight', 'Cp_flight');