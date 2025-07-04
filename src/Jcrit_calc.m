clear;
close all;

load('../data/Jcrit/BEM.mat')
load('../data/Jcrit/wt.mat')
load('../data/Jcrit/flight.mat')

% fit cubic in BEM data and predict Cp_hat_bem
X_Cp_bem = [J_bem J_bem.^2 J_bem.^3];
[B_Cp_bem, FitInfo_Cp_bem] = lasso(X_Cp_bem, Cp_bem, 'Lambda', 1e-10);
intercept_Cp_bem = FitInfo_Cp_bem.Intercept;
coeff_Cp_bem = B_Cp_bem;

Jsynth_bem = linspace(0, 0.93, length(J_bem))';
X_Cpsynth_bem = [Jsynth_bem Jsynth_bem.^2 Jsynth_bem.^3];
Cp_hat_bem = X_Cpsynth_bem * coeff_Cp_bem + intercept_Cp_bem;

% find Jcrit
J_roots_bem = roots([3*coeff_Cp_bem(3) 2*coeff_Cp_bem(2) coeff_Cp_bem(1)]);
fprintf('\nJ_root1 = %.2e\nJ_root2 = %.2e\n', J_roots_bem(1), J_roots_bem(2));

%% plot
figure('Name', 'Cp(J)', 'Position', [600, 400, 600, 400]);

ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2, 'TickLabelInterpreter', 'latex');

hold on;
scatter(J_bem, Cp_bem, 7, 'k', 'filled');
scatter(J_wt, Cp_wt, 9, [253,184,99]/255, 'filled');
scatter(J_flight, Cp_flight, 1, [178,171,210]/255, 'filled');
plot(Jsynth_bem, Cp_hat_bem, 'Color', [230, 97, 1]/255, 'LineWidth', 4, 'LineStyle', ':');
plot([J_roots_bem(2) J_roots_bem(2)], [0 0.077], '--k', 'LineWidth', 0.5);
hold off;

xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
ylim([0 0.1]);
xlim([0 1]);

jcrit_str = sprintf('$J_{crit} = %.2f$', J_roots_bem(2));
h = legend('BEM', 'Wind tunnel', 'Flight test', 'Fitted', jcrit_str);
set(h, 'Interpreter', 'latex', 'FontSize', 14);
legend boxoff;
box on;
