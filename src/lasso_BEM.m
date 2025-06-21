clear; 
close all;

%% user input
load('../data/BEM.mat')
Jcrit = 0.21;

D = 8*0.0254;

idx_Va = 60;
idx_J = 60;

%%
airspeed = data.airspeed;
power = data.power;
rpm = data.rpm;

%%
t = 1:1:10000;
J = airspeed./((rpm/60)*D);
Cp = power./(1.225*D^5*(rpm/60).^3);

%%
datarange = ones(length(t),1);
datarange = datarange & ~isnan(power) ...
                      & J>Jcrit;

%% Fit
[X_Va, names_Va] = genFeatures_Pw(power, rpm*pi/30, -5:1:5, -5:1:5);
[B_Va, FitInfo_Va] = lasso(X_Va(datarange,:), airspeed(datarange), 'CV', 10, 'PredictorNames', names_Va);
lassoPlot(B_Va, FitInfo_Va, 'PlotType', 'CV');

[X_J, names_J] = genFeatures_Cp(Cp, -4:4);
[B_J, FitInfo_J] = lasso(X_J(datarange,:), J(datarange), 'CV', 10, 'PredictorNames', names_J);
lassoPlot(B_J, FitInfo_J, 'PlotType', 'CV');

intercept_Va = FitInfo_Va.Intercept(idx_Va);
coeff_Va = B_Va(:, idx_Va);
intercept_J = FitInfo_J.Intercept(idx_J);
coeff_J = B_J(:, idx_J);

%% Predict timeseries
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;

J_hat = X_J(datarange,:) * coeff_J + intercept_J;
Va_hat2 = J_hat .* (rpm(datarange)/60) * D;

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% plot 
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
    plot(P(:,i), Va, '-', Color='k', LineWidth=2);
    plot(P(:,i), Va_constRPM_hat(:,i), '--', 'Color', [230, 97, 1]/255, 'LineWidth', 2);
    plot(P(:,i), Va_constRPM_hat2(:,i), '--', 'Color', [178,171,210]/255, 'LineWidth', 2);
end
xlabel('$P$ [W]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
ylim([0,30]);
h = legend('BEM', ...
           '$V_a(P,\omega)$', ...
           '$V_a(C_P,\omega)$');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;