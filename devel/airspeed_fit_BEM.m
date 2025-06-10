clear; 
close all;

%% user input
load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/BEM/BEM_t.mat')
p_model_structure = 'bem_reduced';
Cp_model_structure = 'bem_reduced';
Jcrit = 0.24;

D = 8*0.0254; % 9.5 to match power and 7.8 (same dataset) to match Cp(J)

LASSO_EXPLORE = false;
idx_Va = 55;
idx_J = 30;

%%
t = 1:1:10000;
J = airspeed./((rpm/60)*D);
Cp = power./(1.225*D^5*(rpm/60).^3);

%%
datarange = J>Jcrit & ~isnan(power);

%% Fit
if LASSO_EXPLORE
    [X_Va, names_Va] = genFeatures_Pw(power, rpm, -6:1:6, -6:1:6);
    [B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'CV', 10, 'PredictorNames', names_Va);
    % lassoPlot(B_Va, FitInfo_Va, 'PlotType', 'CV');
    
    [X_J, names_J] = genFeatures_Cp(Cp, -4:4);
    [B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'CV', 10, 'PredictorNames', names_J);
    % lassoPlot(B_J, FitInfo_J, 'PlotType', 'CV');
    
    intercept_Va = FitInfo_Va.Intercept(idx_Va);
    coeff_Va = B_Va(:, idx_Va);
    intercept_J = FitInfo_J.Intercept(idx_J);
    coeff_J = B_J(:, idx_J);
else
    [X_Va, names_Va] = model_structure_Pw(power, rpm, [], p_model_structure);
    [B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'Lambda', 1e-10);
    
    [X_J, names_J] = model_structure_Cp(Cp, Cp_model_structure); 
    [B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'Lambda', 1e-10);

    intercept_Va = FitInfo_Va.Intercept;
    coeff_Va = B_Va;
    intercept_J = FitInfo_J.Intercept;
    coeff_J = B_J;
end

%% Predict timeseries
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;
J_hat = X_J(datarange,:) * coeff_J + intercept_J;
Va_hat2 = J_hat .* (rpm(datarange)/60) * D;

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% visualize timeseries
% figure('Name','Va vs sample index');
% hold on;
% plot(t(datarange), airspeed(datarange), 'k', 'LineWidth', 2);
% plot(t(datarange), Va_hat, 'r', 'LineWidth', 1.5);
% plot(t(datarange), Va_hat2, 'g', 'LineWidth', 1.5);
% hold off
% legend('BEM', 'Va(P,w)', 'J(Cp)');
% xlabel('Sample Index');
% ylabel('Airspeed');
% grid on;

%% Predict Va(P, w_const) & visualization
w = zeros(100,1);
P = zeros(100,1);
Va = zeros(100,1);
Va_constRPM_hat = nan(100, 100);
Va_constRPM_hat2 = nan(100, 100);

for c = 1:1:100 % iterate over all rpm values (columns)
    for r = 1:1:100 % airspeed (rows)
        w(c) = rpm(100*(c-1)+r);

        P(r,c) = power(100*(c-1)+r);  
        if c == 1
            Va(r) = airspeed(r);
        end

        Va_constRPM_hat(r,c) = X_Va(100*(c-1)+r,:) * coeff_Va + intercept_Va;
        Va_constRPM_hat2(r,c) = (X_J(100*(c-1)+r,:) * coeff_J + intercept_J) * (w(c)/60) * D;
    end
end

figure('Name','Va(P), w=const')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
for i = 10:10:100
% for i = [30, 50, 70, 80, 90, 100]
    plot(P(:,i), Va, '-', Color='k', LineWidth=2);
    plot(P(:,i), Va_constRPM_hat(:,i), '--', Color='k', LineWidth=1.5);
    plot(P(:,i), Va_constRPM_hat2(:,i), ':', Color='k', LineWidth=1.5);
end
xlabel('$P$ [W]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
ylim([0,30]);
h = legend('BEM', ...
           '$\beta_0 + \beta_1 \omega + \beta_2 \frac{P^2}{\omega^5}$', ...
           '$\frac{\omega}{2\pi}(\alpha_0 + \alpha_1 C_P + \alpha_2 C_P^4)$');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;