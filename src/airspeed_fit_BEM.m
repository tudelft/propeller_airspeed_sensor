clear; 
close all;

%% user input
load('../data/input/BEM.mat')
Jcrit = 0.20;

D = 8*0.0254;

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
[X_Va, names_Va] = model_structure_Pw(power, rpm*pi/30, [], 'bem_reduced');
% scale input matrix to avoid matrix rank numerical issues; p^2/w^5 feature produces very small numbers
X_Va(:,2) = X_Va(:,2)*10^11;
% fit
B_Va = X_Va(datarange,:) \ airspeed(datarange);
% scale back
B_Va(2) = B_Va(2)*10^11;
X_Va(:,2) = X_Va(:,2)*10^-11;

[X_J, names_J] = model_structure_Cp(Cp, 'bem_reduced');    
X_J = [ones(length(X_J),1) X_J]; % add the intercept
% fit
B_J = X_J(datarange,:) \ J(datarange);

intercept_Va = 0;
coeff_Va = B_Va;
intercept_J = B_J(1);
coeff_J = B_J(2:3);

%% Predict
Va_hat = X_Va(datarange,:) * coeff_Va + intercept_Va;

J_hat = X_J(datarange,:) * B_J;
Va_hat2 = J_hat .* (rpm(datarange)/60) * D;

dispModelInfo(airspeed(datarange), Va_hat, names_Va, coeff_Va, intercept_Va);
dispModelInfo(airspeed(datarange), Va_hat2, names_J, coeff_J, intercept_J);

%% plot
w = zeros(100,1);
P = zeros(100,1);
Va = zeros(100,1);
Va_constRPM_hat = nan(100, 100);
Va_constRPM_hat2 = nan(100, 100);

for c = 1:1:100 % iterate over all rpm (datarange)values (columns)
    for r = 1:1:100 % airspeed (rows)
        w(c) = rpm(100*(c-1)+r);

        P(r,c) = power(100*(c-1)+r);  
        if c == 1
            Va(r) = airspeed(r);
        end

        Va_constRPM_hat(r,c) = X_Va(100*(c-1)+r,:) * coeff_Va + intercept_Va;
        Va_constRPM_hat2(r,c) = (X_J(100*(c-1)+r,2:3) * coeff_J + intercept_J) * (w(c)/60) * D;
    end
end


%% visualization
figure('Name','Va(P), omega = const', 'Position', [600, 400, 600, 400]);
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2, 'TickLabelInterpreter', 'latex');

hold on;
for i = 1:11:100
    plot(P(:,i), Va, '-', 'Color', 'k', 'LineWidth', 2);
    plot(P(:,i), Va_constRPM_hat(:,i), '--', 'Color', [230, 97, 1]/255, 'LineWidth', 2);
    plot(P(:,i), Va_constRPM_hat2(:,i), '--', 'Color', [178,171,210]/255, 'LineWidth', 2);
end
hold off;

xlabel('$P$ [W]', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$V_a$ [m/s]', 'Interpreter', 'latex', 'FontSize', 14);
xlim([0, 175]);
ylim([0, 30]);

h = legend('BEM', ...
           '$\beta_1 \omega + \beta_2 \frac{P^2}{\omega^5}$', ...
           '$\frac{\omega}{2\pi}(\alpha_0 + \alpha_1 C_P + \alpha_2 C_P^4)$', ...
           'Interpreter', 'latex', 'FontSize', 14);
legend boxoff;
box on;

%% save the models
% save('../models/BEM.mat', 'names_Va', 'coeff_Va');
% save('../models/BEM_j.mat', 'names_J', 'coeff_J', 'intercept_J');

%% save data for Jcrit calculation
% J_bem = J; Cp_bem = Cp;
% save('../data/Jcrit/BEM.mat', 'J_bem', 'Cp_bem');