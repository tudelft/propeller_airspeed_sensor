clear;
close all;

load('../data/Jcrit/BEM.mat')
load('../data/eff/flight.mat')

% fit cubic in BEM data and predict Cp_hat_bem
X_Cp_bem = [J_bem J_bem.^2 J_bem.^3];
[B_Cp_bem, FitInfo_Cp_bem] = lasso(X_Cp_bem, Cp_bem, 'Lambda', 1e-10);
intercept_Cp_bem = FitInfo_Cp_bem.Intercept;
coeff_Cp_bem = B_Cp_bem;

Jsynth_bem = linspace(0, 0.93, length(J_bem))';
X_Cpsynth_bem = [Jsynth_bem Jsynth_bem.^2 Jsynth_bem.^3];
Cp_hat_bem = X_Cpsynth_bem * coeff_Cp_bem + intercept_Cp_bem;

% fit cubic in flight data and predict Cp_hat_flight
X_Cp_flight = [J_flight J_flight.^2 J_flight.^3];
[B_Cp_flight, FitInfo_Cp_flight] = lasso(X_Cp_flight, Cp_flight, 'Lambda', 1e-10);
intercept_Cp_flight = FitInfo_Cp_flight.Intercept;
coeff_Cp_flight = B_Cp_flight;

Jsynth_flight = Jsynth_bem;
X_Cpsynth_flight = X_Cpsynth_bem;
Cp_hat_flight = X_Cpsynth_flight * coeff_Cp_flight + intercept_Cp_flight;

% find efficiency n by fitting n*Cp_hat_flight model to Cp_hat_bem data
n = Cp_hat_flight \ Cp_hat_bem;

% plot
figure('Name','efficiency')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
scatter(J_bem, Cp_bem, 7, 'k', 'filled');
plot(Jsynth_bem, Cp_hat_bem, 'Color', [230, 97, 1]/255, 'LineWidth', 4, 'LineStyle', ':');
plot(Jsynth_bem, 1/n * Cp_hat_bem, 'Color', [230, 97, 1]/255, 'LineWidth', 2.5, 'LineStyle', ':');
scatter(J_flight, Cp_flight, 1, [178,171,210]/255, 'filled');
hold off;
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
xlim([0 0.9])
ylim([0 0.12])
h = legend('BEM', 'Cubic fit in BEM', '$(1/\eta)\;\times$ Cubic fit in Flight test', 'Flight test');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
xlim([0 1]);