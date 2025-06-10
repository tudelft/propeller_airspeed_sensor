% Need to run the appropriate "airspeed_fit" script first

%% BEM data
J(isinf(J)) = NaN;
Cp(isinf(Cp)) = NaN;
Cp(Cp > 0.1) = NaN;

X_Cp = [J J.^2 J.^3];
[B_Cp, FitInfo_Cp] = lasso(X_Cp, Cp, 'Lambda', 1e-10);
intercept_Cp = FitInfo_Cp.Intercept;
coeff_Cp = B_Cp;

Jsynth = linspace(0, 0.93, length(J(datarange)))';
X_Cpsynth = [Jsynth Jsynth.^2 Jsynth.^3];
Cp_hat = X_Cpsynth * coeff_Cp + intercept_Cp;

figure('Name','Cp(J)')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
scatter(J, Cp, 3, 'k', 'filled');
plot(Jsynth, Cp_hat, 'r', LineWidth=2, LineStyle='--');
plot([0.24 0.24], [0 0.093], '--k', 'LineWidth', 0.5);
hold off;
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
ylim([0 0.12])
h = legend('BEM', 'Fitted', '$J_{crit}=$ 0.24');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
xlim([0 1]);

% Find the minimums/maximums of fitted Cp(J)
% dCp_dJ = coeff_Cp(1)*ones(length(J),1) + 2*coeff_Cp(2)*J + 3*coeff_Cp(3)*J.^2;
J_roots = roots([3*coeff_Cp(3) 2*coeff_Cp(2) coeff_Cp(1)]);
fprintf('\nJ_root1 = %.2e\nJ_root2 = %.2e\n', J_roots(1), J_roots(2));

%% WT data
datarange = zeros(length(t),1);
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    idx = t >= trange(1) & t <= trange(2);
    datarange = datarange | idx;
end
datarange = logical(datarange);

datarange = datarange & airspeed>1 & power>50 & rpm_dot<400 & rpm_dot>-400;

X_Cp = [J J.^2 J.^3];
[B_Cp, FitInfo_Cp] = lasso(X_Cp(datarange,:), Cp(datarange), 'Lambda', 1e-10);
intercept_Cp = FitInfo_Cp.Intercept;
coeff_Cp = B_Cp;

Jsynth = linspace(0, 0.85, length(J(datarange)))';
X_Cpsynth = [Jsynth Jsynth.^2 Jsynth.^3];
Cp_hat = X_Cpsynth * coeff_Cp + intercept_Cp;

figure('Name','Cp(J)')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
scatter(J(datarange), Cp(datarange), 12, 'k', 'filled');
plot(Jsynth, Cp_hat, 'r', LineWidth=2, LineStyle='--');
plot([0.21 0.21], [0 0.099], '--k', 'LineWidth', 0.5);
hold off;
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
ylim([0 0.12])
h = legend('Wind tunnel', 'Fitted', '$J_{crit}=$ 0.21');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
xlim([0 1]);

J_roots = roots([3*coeff_Cp(3) 2*coeff_Cp(2) coeff_Cp(1)]);
fprintf('\nJ_root1 = %.2e\nJ_root2 = %.2e\n', J_roots(1), J_roots(2));

%% Flight data
% 0254
tranges = [780 908];
datarange = zeros(length(t),1);
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    idx = t >= trange(1) & t <= trange(2);
    datarange = datarange | idx;
end
datarange = logical(datarange);

datarange = datarange & rpm_dot<500 & rpm_dot>-500;

% X_Cp = [J J.^2 J.^3];
% [B_Cp, FitInfo_Cp] = lasso(X_Cp(datarange,:), Cp(datarange), 'Lambda', 1e-10);
% intercept_Cp = FitInfo_Cp.Intercept;
% coeff_Cp = B_Cp;

% hardcoded
% coeff_Cp = [0.0341; -0.0535; -0.1101];
coeff_Cp = [0.0221; -0.002; -0.1481];
intercept_Cp = 0.0843;

Jsynth = linspace(0, 0.9, length(J(datarange)))';
X_Cpsynth = [Jsynth Jsynth.^2 Jsynth.^3];
Cp_hat = X_Cpsynth * coeff_Cp + intercept_Cp;

figure('Name','Cp(J)')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
scatter(J(datarange), Cp(datarange), 12, 'k', 'filled');
plot(Jsynth, Cp_hat, 'r', LineWidth=2, LineStyle='--');
plot([0.23 0.23], [0 0.087], '--k', 'LineWidth', 0.5);
hold off;
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
ylim([0 0.12])
h = legend('Flight data', 'Fitted', '$J_{crit}=$ 0.23');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 11)
legend boxoff;
box on;
xlim([0 1])

J_roots = roots([3*coeff_Cp(3) 2*coeff_Cp(2) coeff_Cp(1)]);
fprintf('\nJ_root1 = %.2e\nJ_root2 = %.2e\n', J_roots(1), J_roots(2));