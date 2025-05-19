clear; 
close all;

%% user input
load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/BEM/BEM_t.mat')
LASSO_EXPLORE = false;
idx_Va = 50;
idx_J = 70;

%%
t = 1:1:10000;
J = airspeed./((rpm/60)*(10*0.0254));
Cp = power./(1.225*(10*0.0254)^5*(rpm/60).^3);

%%
datarange = J>0.2 & ~isnan(power);

%% Fit
if LASSO_EXPLORE
    [X_Va, names_Va] = genFeatures_Pw(power, rpm, -6:1:6, -6:1:6);
    [B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'CV', 10, 'PredictorNames', names_Va);
    lassoPlot(B_Va, FitInfo_Va, 'PlotType', 'CV');
    
    [X_J, names_J] = genFeatures_Cp(Cp, -4:4);
    [B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'CV', 10, 'PredictorNames', names_J);
    lassoPlot(B_J, FitInfo_J, 'PlotType', 'CV');
    
    intercept_Va = FitInfo_Va.Intercept(idx_Va);
    coeff_Va = B_Va(:, idx_Va);
    intercept_J = FitInfo_J.Intercept(idx_J);
    coeff_J = B_J(:, idx_J);
else
    X_Va = [power.^(-1).*rpm.^5 ,...
            power.^(-1).*rpm.^6, ...
            power.^(1).*rpm.^-3];
    names_Va = {'p^-1_w^5', 'p^-1_w^6', 'p^1_w^-3'};
    [B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'Lambda', 1e-10);
    
    X_J = [Cp.^-3 Cp.^-1 Cp.^2];
    % X_J = [Cp.^1 Cp.^4];
    names_J = {'Cp^-3', 'Cp^-1', 'Cp^2'};
    % names_J = {'Cp^1', 'Cp^4'};
    [B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'Lambda', 1e-10);

    intercept_Va = FitInfo_Va.Intercept;
    coeff_Va = B_Va;
    intercept_J = FitInfo_J.Intercept;
    coeff_J = B_J;
end

%% Predict timeseries
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;
J_hat = X_J(datarange,:) * coeff_J + intercept_J;
Va_hat2 = J_hat .* (rpm(datarange)/60) * (10*0.0254);

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J);

% figure;
% plot(t(datarange), airspeed(datarange), 'k', 'LineWidth', 1.5); hold on;
% plot(t(datarange), Va_hat, 'r', 'LineWidth', 1.5);
% plot(t(datarange), Va_hat2, 'g', 'LineWidth', 1.5);
% legend('BEM Airspeed', 'Predicted from Va(P,w) model', 'Predicted from J(Cp) model');
% xlabel('Sample Index');
% ylabel('Airspeed');
% title('BEM Airspeed prediction');
% grid on;

%% Predict Va(P, w_const) & visualization
w = zeros(100,1);
P = zeros(100,1);
Va = zeros(100,1);
Va_constRPM_hat = nan(100, 100);
Va_constRPM2_hat = nan(100, 100);

for c = 1:1:100 % iterate over all rpm values (columns)
    for r = 1:1:100 % airspeed (rows)
        w(c) = rpm(100*(c-1)+r);

        P(r,c) = power(100*(c-1)+r);  
        if c == 1
            Va(r) = airspeed(r);
        end

        Va_constRPM_hat(r,c) = X_Va(100*(c-1)+r,:) * coeff_Va + intercept_Va;
        Va_constRPM2_hat(r,c) = (X_J(100*(c-1)+r,:) * coeff_J + intercept_J) * (w(c)/60) * (10*0.0254);
    end
end

figure('Name','Va(P) for const w')
hold on;
for i = 10:10:100
    plot(P(:,i), Va, '-', Color='k', LineWidth=1.2);
    plot(P(:,i), Va_constRPM_hat(:,i), '-', Color='r', LineWidth=1.2);
    plot(P(:,i), Va_constRPM2_hat(:,i), '-', Color='g', LineWidth=1.2);
end
xlabel('$P$ (W)', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ ($\frac{m}{s}$)', 'FontSize', 14, 'Interpreter', 'latex');
legend('BEM Airspeed', 'Predicted from Va(P,w) model', 'Predicted from J(Cp) model');