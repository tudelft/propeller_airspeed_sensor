clear;
close all;

%% user input
load('../data/input/wt.mat')
Jcrit = 0.20;

D = 8*0.0254;
efficiency = 0.874;

%%
airspeed = data.airspeed;
rpm = data.rpm;
voltage = data.voltage;
current = data.current;
t = data.t;
fs = data.fs;

power = voltage.*current*efficiency;

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

rpm = filtfilt(b,a,rpm);
power = filtfilt(b,a,power);

%%
J = airspeed./((rpm/60)*D);
Cp = power./(1.225*D^5*(rpm/60).^3);

%% derivatives
rpm_dot = [zeros(1,1); diff(rpm,1)]*fs;

%%
datarange = ones(length(t),1);
datarange = datarange & power>20 ...                   % avoid windmilling
                      & rpm_dot<500 & rpm_dot>-500 ... % remove transients; keep steady state
                      & rpm<10000 ...                  % motor gets hot and R changes
                      & J>Jcrit;                       % the selection criterion

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

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va(1:2), intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% visualization
t_compact = 1:length(t(datarange));

% airspeed
figure('Name','Airspeed fit using Airspeed data', 'Position', [200, 400, 600, 400]);

ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');

hold on;
scatter(t_compact, airspeed(datarange), 9, 'k', 'filled');
scatter(t_compact, Va_hat, 3, [230, 97, 1]/255, 'filled');
scatter(t_compact, Va_hat2, 3, [178,171,210]/255, 'filled');
hold off;

xlabel('Sample index', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');

h = legend('Wind tunnel', ...
           '$\beta_1 \omega + \beta_2 \frac{P^2}{\omega^5}$', ...
           '$\frac{\omega}{2\pi}(\alpha_0 + \alpha_1 C_P + \alpha_2 C_P^4)$');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 14);
legend boxoff;
box on;
axis padded;


% PRM
figure('Name','Airspeed fit using Airspeed data', ...
       'Position', [900, 400, 600, 400]);

ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');

scatter(t_compact, rpm(datarange), 6, [0, 0, 0], 'filled');

xlabel('Sample index', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$\omega$ [RPM]', 'FontSize', 14, 'Interpreter', 'latex');

ax.YAxis.Exponent = 3;
ax.YRuler.SecondaryLabel.String = '$\times 10^3$';
ax.YRuler.SecondaryLabel.Interpreter = 'latex';
ax.YRuler.SecondaryLabel.FontSize = 14;

box on;
axis padded;

%% save models
% save('../models/WT.mat', 'names_Va', 'coeff_Va');
% save('../models/WT_j.mat', 'names_J', 'coeff_J', 'intercept_J');

%% save data for Jcrit calculation
% J_wt = J(datarange) ; Cp_wt = Cp(datarange);
% save('../data/Jcrit/wt.mat', 'J_wt', 'Cp_wt');
