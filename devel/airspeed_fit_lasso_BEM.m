clear; 
close all;

%% load dataset
load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/BEM/BEM_t.mat')

%%
t = 1:1:10000;
J = airspeed./((rpm/60)*(10*0.0254));
Cp = power./(1.225*(10*0.0254)^5*(rpm/60).^3);

%%
datarange = J > 0.25 & ~isnan(power);

% [~, ~, ic] = unique(rpm);
% datarange_rpm = false(length(datarange), 100);
% for i = 1:1:100
%     mask = ic==i;
%     datarange_rpm(:,i) = datarange & mask;
% end

%% Fit for Va
[X_Va, names_Va] = genFeatures_Pw(power, rpm, -10:1:10, -10:1:10);
[B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'CV', 10);
lassoPlot(B_Va, FitInfo_Va, 'PlotType', 'CV');

%% Fit for J
[X_J, names_J] = genFeatures_Cp(Cp, -4:4);
[B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'CV', 10);
lassoPlot(B_J, FitInfo_J, 'PlotType', 'CV');

%% 
idx_Va = 42;
idx_J = 75;

intercept_Va = FitInfo_Va.Intercept(idx_Va);
coeff_Va = B_Va(:, idx_Va);
intercept_J = FitInfo_J.Intercept(idx_J);
coeff_J = B_J(:, idx_J);

dispModelInfo(FitInfo_Va, names_Va, coeff_Va, idx_Va);
dispModelInfo(FitInfo_J, names_J, coeff_J, idx_J);
%% Predict timeseries
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;
J_hat = X_J(datarange,:) * coeff_J + intercept_J;

figure;
plot(airspeed(datarange), 'k', 'LineWidth', 1.5); hold on;
plot(Va_hat, 'r', 'LineWidth', 1.5);
plot(J_hat .* (rpm(datarange)/60) * (10*0.0254), 'g', 'LineWidth', 1.5);
legend('BEM Airspeed', 'Predicted from Va(P,w) model', 'Predicted from J(Cp) model');
xlabel('Sample Index');
ylabel('Airspeed');
title('Lasso Airspeed timeseries prediction');
grid on;

%% Predict Va(P, w_const)
w = zeros(100,1);
P = zeros(100,1);
Va = zeros(100,1);
Va_constRPM_hat = nan(100, 100);

for c = 1:1:100 % iterate over all rpm values (columns)
    for r = 1:1:100 % airspeed (rows)
        Va_constRPM_hat(r,c) = X_Va(100*(c-1)+r,:) * coeff_Va + intercept_Va;
        J_constRPM_hat(r,c) = X_J(100*(c-1)+r,:) * coeff_J + intercept_J;

        P(r,c) = power(100*(c-1)+r);  
        if c == 1
            Va(r) = airspeed(r);
        end
    end
    w(c) = rpm(100*(c-1)+r);
end

figure('Name','Va(P) for const w')
hold on;
for i = 10:10:100
    plot(P(:,i), Va, '-', Color='k', LineWidth=1.2);
    plot(P(:,i), Va_constRPM_hat(:,i), '-', Color='r', LineWidth=1.2);
    plot(P(:,i), J_constRPM_hat(:,i) * (w(i)/60) * (10*0.0254), '-', Color='g', LineWidth=1.2);
end
xlabel('$P$ (W)', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ ($\frac{m}{s}$)', 'FontSize', 14, 'Interpreter', 'latex');
legend('BEM Airspeed', 'Predicted from Va(P,w) model', 'Predicted from J(Cp) model');