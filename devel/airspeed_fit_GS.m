clear;
close all;

%% user input
THETA_SELECTION = false;
p_model_structure = 'bem_reduced_wdot';

D = 8*0.0254;

load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/0254.mat')
tranges = [846 908];

%%
t = ac_data.AIR_DATA.timestamp;
fs = 500;
t = (t(1):1/fs:t(end))';

%%
gyro_p = interp1(ac_data.IMU_GYRO_SCALED.timestamp, ...
                 ac_data.IMU_GYRO_SCALED.gp_alt, t, 'linear', 'extrap')*pi/180;

airspeed = interp1(ac_data.AIR_DATA.timestamp, ...
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
psi = interp1(ac_data.EULER.timestamp, ac_data.EULER.psi, t, 'linear', 'extrap');
psi = psi*pi/180;

Vnorth = interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.vnorth_alt, t, 'linear', 'extrap');
Veast = interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.veast_alt, t, 'linear', 'extrap');

%% calibrate airspeed
[corr_factor, VWN, VWE] = calib_airspeed(airspeed, Vnorth, Veast, psi, t, tranges);
airspeed = corr_factor * airspeed;

%% filter with Butterworth
filter_freq = 5;
[b, a] = butter(2,filter_freq/(fs/2));

airspeed = filtfilt(b,a,airspeed);
rpm = filtfilt(b,a,rpm);
power= filtfilt(b,a,power);

%%
J = airspeed./((rpm/60)*D);

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

if THETA_SELECTION
    % probably better to use theta rate here, theta limits are not symmetrical either
    datarange = datarange & airspeed>5 & power>10 & (theta<-70 & theta>-110);
else
    datarange = datarange & airspeed>5 & power>10;
end

datarange = datarange & J>0.3;

%% Fit
Y1 = Vnorth - VWN; 
Y2 = Veast - VWE;

[X, names] = model_structure_Pw(power, rpm, rpm_dot, p_model_structure);
X1 = [ones(length(t),1) X] .* cos(psi);
X2 = [ones(length(t),1) X] .* sin(psi);

% not the proper way. Normally we d like to fit without an intercept.
% However X needs to be standardized and lasso handles that nicely so
% keep an eye on the intercept, as long as it is small it is ok.
[B, FitInfo] = lasso([X1(datarange,:); X2(datarange,:)], [Y1(datarange); Y2(datarange)], ...
                     'Lambda', 1e-10);
intercept = FitInfo.Intercept;
coeff = B;

%% Predict
Va_north_hat = X1(datarange,:) * coeff;
Va_east_hat = X2(datarange,:) * coeff;
Va_hat = sqrt(Va_north_hat.^2 + Va_east_hat.^2);

dispModelInfo(airspeed(datarange), Va_hat, names, coeff(2:end), intercept);

%% visualize the regular fit in the same plot
% first run airspeed fit
% then the run 
% Va_hat_fit = Va_hat;
% and 
% t_fit = t(datarange);
% the run airspeed_fit_GS WITHOUT CLEARING THE WORKSPACE

%% visualization
figure('Name','Airspeed fit with Ground Speed data');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
plot(t(datarange), airspeed(datarange), 'k-',  LineWidth=2);
% plot(t_fit, Va_hat_fit, 'r-',  LineWidth=1.5);
plot(t(datarange), Va_hat, 'g-',  LineWidth=1.5);
xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
% h = legend('Pitot', ...
%            '$\beta_0 + \beta_1 \omega + \beta_2 \frac{P^2}{\omega^5} + \beta_3 \omega \dot{\omega} $');
h = legend('Pitot', ...
           'Fit using Airspeed', ...
           'Fit using Ground speed');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
axis padded