clear;
close all;

%% user input
load('./data/test.mat')

load('./models/BEM.mat')
coeff_Va_BEM = coeff_Va;
load('./models/WT.mat')
coeff_Va_WT = coeff_Va;
load('./models/flight_AS.mat')
coeff_Va_AS = coeff_Va;
load('./models/flight_GS.mat')
coeff_Va_GS = coeff_Va;

load('./models/BEM_j.mat')
coeff_J_BEM = coeff_J;
intercept_J_BEM = intercept_J;
load('./models/WT_j.mat')
coeff_J_WT = coeff_J;
intercept_J_WT = intercept_J;
load('./models/flight_AS_j.mat')
coeff_J_AS = coeff_J;
intercept_J_AS = intercept_J;
load('./models/flight_GS_j.mat')
coeff_J_GS = coeff_J;
intercept_J_GS = intercept_J;

p_model_structure = 'bem_reduced';
Cp_model_structure = 'bem_reduced';

D = 8*0.0254;
R = 0.072;
motor_arm = 0.24;

Jcrit = 0.21;
alpha_crit = 30*pi/180;

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

power = voltage.*current - current.^2*R;
airspeed = airspeed - gyrop*motor_arm;
velocity = sqrt(Vnorth.^2 + Veast.^2 + Vdown.^2);

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
% datarange = zeros(length(t),1);
% for i = 1:size(tranges,1)
%     trange = tranges(i,:);
%     idx = t >= trange(1) & t <= trange(2);
%     datarange = datarange | idx;
% end
% datarange = logical(datarange);
datarange = ones(length(t),1);
% datarange = datarange & J>Jcrit;
gamma = asin(-Vdown./velocity);
theta = theta + pi/2;
alpha = theta - gamma;
datarange = datarange & alpha<alpha_crit;

%%
[X_Va, names_Va] = model_structure_Pw(power, rpm, rpm_dot, p_model_structure);
intercept_Va = 0;

[X_J, names_J] = model_structure_Cp(Cp, Cp_model_structure);

%% Predict
Va_hat_BEM = X_Va(datarange,:) * coeff_Va_BEM + intercept_Va;
Va_hat_WT = X_Va(datarange,:) * coeff_Va_WT + intercept_Va;
Va_hat_AS = X_Va(datarange,:) * coeff_Va_AS + intercept_Va;
Va_hat_GS = X_Va(datarange,:) * coeff_Va_GS + intercept_Va;

J_hat_BEM = X_J(datarange,:) * coeff_J_BEM + intercept_J_BEM;
Va_hat2_BEM = J_hat_BEM .* (rpm(datarange)/60) * D;
J_hat_WT = X_J(datarange,:) * coeff_J_WT + intercept_J_WT;
Va_hat2_WT = J_hat_WT .* (rpm(datarange)/60) * D;
J_hat_AS = X_J(datarange,:) * coeff_J_AS + intercept_J_AS;
Va_hat2_AS = J_hat_AS .* (rpm(datarange)/60) * D;
J_hat_GS = X_J(datarange,:) * coeff_J_GS + intercept_J_GS;
Va_hat2_GS = J_hat_GS .* (rpm(datarange)/60) * D;

disp("BEM metrics");
dispModelInfo(airspeed(datarange), Va_hat_BEM, names_Va, coeff_Va_BEM, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_BEM, names_J, coeff_J_BEM, intercept_J_BEM);
disp("WT metrics");
dispModelInfo(airspeed(datarange), Va_hat_WT, names_Va, coeff_Va_WT, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_WT, names_J, coeff_J_WT, intercept_J_WT);
disp("AS metrics");
dispModelInfo(airspeed(datarange), Va_hat_AS, names_Va, coeff_Va_AS, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_AS, names_J, coeff_J_AS, intercept_J_AS);
disp("GS metrics");
dispModelInfo(airspeed(datarange), Va_hat_GS, names_Va, coeff_Va_GS, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2_GS, names_J, coeff_J_GS, intercept_J_GS);

%% 
figure('Name','Angle of Attack and Advance Ratio');

ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2, 'TickLabelInterpreter', 'latex');
box on;
axis padded;

% Left Y-axis
yyaxis left
plot(t, rad2deg(alpha), 'Color', [0,0,0]/255, 'LineWidth', 1);
ylabel('$\alpha$ [deg]', 'FontSize', 14, 'Interpreter', 'latex');
ax.YColor = [0,0,0]/255;
% Right Y-axis
yyaxis right
hold on
plot(t, J, 'Color', [230,97,1]/255, 'LineWidth', 1);
yline(Jcrit, '--', 'Color', [230,97,1]/255, 'LineWidth', 1);
hold off;
ylabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ax.YColor = [230,97,1]/255;
% Shared X-axis
xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');

h = legend('$\alpha$', '$J$', '$J_\mathrm{crit}=0.21$');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11);
legend boxoff;
box on;
axis padded


%% visualization
figure('Name','Va predict');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
plot(t(datarange), airspeed(datarange), '-', 'Color', 'k', 'LineWidth', 2);
scatter(t(1:20:end), airspeed(1:20:end), 5, 'k', 'filled');
plot(t(datarange), Va_hat_BEM, '-', 'Color', [178,171,210]/255, 'LineWidth', 0.6); % deep purple , [94,60,153]/255 dark 
% plot(t(datarange), Va_hat_AS, '-', 'Color', [253,184,99]/255, 'LineWidth', 0.6);   % yellow-like
plot(t(datarange), Va_hat_GS, '-', 'Color', [230,97,1]/255, 'LineWidth', 0.6); % orange-like
hold off;
xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
h = legend('Pitot', 'No estimate', '$V_a(P,\omega)$ - trained on BEM', '$V_a(P,\omega)$ - trained on GPS');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
axis padded