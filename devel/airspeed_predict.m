clear;
close all;

%% user input
THETA_SELECTION = false;
p_model_structure = 'bem_reduced_wdot';

load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/flight/144.mat')
load('/home/ntouev/MATLAB/propeller_airspeed_sensor/models/0254.mat')

% 144
corr_factor = 0.94;
tranges = [250 326];

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

%% calibrate airspeed
airspeed = corr_factor * airspeed;

%% filter with Butterworth
filter_freq = 2;
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

if THETA_SELECTION
    % probably better to use theta rate here, theta limits are not symmetrical either
    datarange = datarange & airspeed>5 & power>10 & (theta<-70 & theta>-110);
else
    datarange = datarange & airspeed>5 & power>10;
end

datarange = datarange & J>0.3;

%%
[X_Va, names_Va] = model_structure_Pw(power, rpm, rpm_dot, p_model_structure);

%% Predict
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;
dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va, intercept_Va);

%% visualization
figure('Name','Va predict');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
plot(t(datarange), airspeed(datarange), 'k-', LineWidth=2);
plot(t(datarange), Va_hat, 'r-', LineWidth=1.5);
hold off;
xlabel('$t$ [s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
h = legend('Pitot', '$\beta_0 + \beta_1 \omega + \beta_2 \frac{P^2}{\omega^5} + \beta_3 \omega \dot{\omega} $');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
axis padded