% Need to run the appropriate "airspeed_fit" script first

%% BEM data
X_Cp = [J J.^2 J.^3];
[B_Cp, FitInfo_Cp] = lasso(X_Cp, Cp, 'Lambda', 1e-10);

intercept_Cp = FitInfo_Cp.Intercept;
coeff_Cp = B_Cp;

Jsynth = linspace(0, 0.7, length(J(datarange)))';
X_Cpsynth = [Jsynth Jsynth.^2 Jsynth.^3];
Cp_hat = X_Cpsynth * coeff_Cp + intercept_Cp;
names_Cp = {'J', 'J^2', 'J^3'};

% weird hardcoded stuff to get rid of NaNs and calculate RMSE properly
% tempCp = Cp(J<=0.7);
% tempCp(isnan(tempCp)) = 0;
% tempCp_hat = Cp_hat(J<=0.7);
% tempCp_hat(isnan(tempCp_hat)) = 0;
% dispModelInfo(tempCp, tempCp_hat, names_Cp, coeff_Cp, intercept_Cp);

figure('Name','Cp(J)')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
scatter(J, Cp, 3, 'k', 'filled');
plot(Jsynth, Cp_hat, 'r', LineWidth=2, LineStyle='--');
hold off;
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 16, 'Interpreter', 'latex');
ylim([0 0.04])
h = legend('BEM', 'Fitted');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 13)
legend boxoff;
box on;

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

% rpm dot should nt matter a lot, power changes the peak
datarange = datarange & airspeed>1 & power>60 & rpm_dot<500 & rpm_dot>0;

X_Cp = [J J.^2 J.^3];
[B_Cp, FitInfo_Cp] = lasso(X_Cp(datarange,:), Cp(datarange), 'Lambda', 1e-10);
intercept_Cp = FitInfo_Cp.Intercept;
coeff_Cp = B_Cp;

Jsynth = linspace(0, 0.7, length(J(datarange)))';
X_Cpsynth = [Jsynth Jsynth.^2 Jsynth.^3];
Cp_hat = X_Cpsynth * coeff_Cp + intercept_Cp;
names_Cp = {'J', 'J^2', 'J^3'};

figure('Name','Cp(J)')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
scatter(J(datarange), Cp(datarange), 12, 'k', 'filled');
plot(Jsynth, Cp_hat, 'r', LineWidth=2, LineStyle='--');
hold off;
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 16, 'Interpreter', 'latex');
ylim([0 0.04])
h = legend('Windtunnel', 'Fitted');
set(h, 'Interpreter', 'latex');
set(h, 'FontSize', 13)
legend boxoff;
box on;

J_roots = roots([3*coeff_Cp(3) 2*coeff_Cp(2) coeff_Cp(1)]);
fprintf('\nJ_root1 = %.2e\nJ_root2 = %.2e\n', J_roots(1), J_roots(2));

%% Flight data

