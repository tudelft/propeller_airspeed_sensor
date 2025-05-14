% clear; 
close all;

%% load dataset
load('/home/ntouev/MATLAB/propeller_airspeed_sensor/post_data/BEM/BEM_t.mat')

%%
t = 1:1:10000;
J = airspeed./((rpm/60)*(10*0.0254));
Cp = power./(1.225*(10*0.0254)^5*(rpm/60).^3);

% Cp22 = P./(1.225*(10*0.0254)^5*(w./60).^3);
Cp22 = zeros(100,100);
for i = 1:100
    for j = 1:100
        Cp22(j,i) = P(j,i)/(1.225*(10*0.0254)^5*(w(i)/60)^3);
    end
end


%%
% dCp_dJ = gradient(Cp, J);
% dP_dVa_all = zeros(100,100);
% for i = 1:100
%     dP_dVa = gradient(P(:,i), Va);
%     dP_dVa_all(:,i) = dP_dVa(:);
% end
% 
% figure('Name','dP/dVa, w = const'); 
% hold on;
% grid on;
% for i = 10:10:100
%    plot(Va, dP_dVa_all(:,i), Color='k'); 
% end
% hold off;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:dPdVa_wconst.eps');

%%
datarange = J > 0.25 & ~isnan(power);

%% Fitting for Cp
% input = [J(datarange) J(datarange).^2];
% output = Cp(datarange);
% 
% mdl_cp = fitlm(input, output, "linear", 'Intercept', true);
% 
% fprintf('R^2: %.2f\n', mdl_cp.Rsquared.Ordinary);
% fprintf('Coeff: '); fprintf('%.8f ', mdl_cp.Coefficients.Estimate); fprintf("\n");
% 
% figure('Name','Cp fit');
% hold on; grid on; zoom on;
% plot(J(datarange), output, '.', MarkerEdgeColor='k', DisplayName="Real");
% plot(J(datarange), mdl_cp.Fitted, '.', MarkerEdgeColor='r', DisplayName="Predicted");
% xlabel('J');
% ylabel('Cp');
% title('Cp(J)');
% legend('show');
% hold off;

%% Invert to find airspeed
% a0 = mdl_power.Coefficients.Estimate(1);
% a1 = mdl_power.Coefficients.Estimate(2);
% a2 = mdl_power.Coefficients.Estimate(3);
% 
% J_pred = (-a1 - sqrt(a1^2 - 4*a2*(a0-Cp(datarange))))/(2*a2);
% Va_pred = J_pred.*(rpm(datarange)/60)*10*0.0254;
% 
% figure('Name','Airspeed from Inversion');
% hold on; grid on; zoom on;
% plot(t(datarange), airspeed(datarange), '.', MarkerEdgeColor='b', MarkerSize=10, DisplayName="Real");
% plot(t(datarange), Va_pred, '.', MarkerEdgeColor='r', MarkerSize=10, DisplayName="Predicted");
% xlabel('t [sec]');
% ylabel('Va [m/s]');
% title('Airspeed');
% legend('show');
% hold off;

%% directly fitting for J(Cp)
input = [Cp(datarange) Cp(datarange).^2];
output = J(datarange);

mdl_j = fitlm(input, output, "linear", 'Intercept', true);

fprintf('R^2: %.2f\t', mdl_j.Rsquared.Ordinary);
fprintf('Coeff: '); fprintf('%.8f ', mdl_j.Coefficients.Estimate); fprintf("\n");

figure('Name','J(Cp) fit');
ax = gca; 
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
plot(Cp(:), J, '.', MarkerEdgeColor='k', DisplayName="Real");
plot(Cp(datarange), mdl_j.Fitted, '.', MarkerEdgeColor='r', DisplayName="Predicted");
hold off;
xlabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$J$', 'FontSize', 14, 'power(datarange).^2)./(rpm(datarange).^5)];Interpreter', 'latex');
box on;
legend boxoff;

set(gcf, 'Renderer', 'painters');  
print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:J-vs-Cp_fit.eps');

gamma0 = mdl_j.Coefficients.Estimate(1) * (10*0.0254)/60;
gamma1 = mdl_j.Coefficients.Estimate(2) * ((10*0.0254)/60) / (1.225/60^3 * (10*0.0254)^5);
gamma2 = mdl_j.Coefficients.Estimate(3) * ((10*0.0254)/60) / (1.225^2/60^6 * (10*0.0254)^10);

%% fitting for Va(P,omega)
input = [power(datarange) rpm(datarange), ...
         power(datarange).^2 rpm(datarange).^2, ...
         power(datarange).*rpm(datarange)];

output = airspeed(datarange);

mdl_va = fitlm(input, output, "linear", 'Intercept', true);

%% Predict 
Va_pred_all = zeros(100, 100);
Va_pred_allJ = zeros(100, 100);

for i = 1:1:100
    input = [P(:,i) w(i)*ones(100,1), ...
             P(:,i).^2 (w(i)*ones(100,1)).^2, ...
             P(:,i).*(w(i)*ones(100,1))];

    Va_pred = predict(mdl_va,input);
    Va_pred_all(:, i) = Va_pred;
    
    input = [Cp22(:,i) Cp22(:,i).^2];
    J_pred = predict(mdl_j, input);
    Va_pred_allJ(:,i) = J_pred.*(w(i)*ones(100,1)/60)*(10*0.0254);
end

%% plotting
% fprintf('R^2: %.2f\n', mdl_va.Rsquared.Ordinary);
fprintf('mdl_va Coeff: '); fprintf('%.8f ', mdl_va.Coefficients.Estimate); fprintf("\n");
fprintf('mdl_j Coeff: '); fprintf('%.8f ', mdl_j.Coefficients.Estimate); fprintf("\n");

figure('Name','Va(P) for const w')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
hold on;
for i = 10:10:100
    plot(P(:,i), Va, '-', Color='k', LineWidth=1.2);
    plot(P(:,i), Va_pred_all(:,i), '-', Color='r', LineWidth=1.2);
    plot(P(:,i), Va_pred_allJ(:,i), '-', Color='g', LineWidth=1.2);
end
hold off;
xlabel('$P$ (W)', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$V_a$ ($\frac{m}{s}$)', 'FontSize', 14, 'Interpreter', 'latex');
box on;
% legend boxoff;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:Va-vs-P+w_fit.eps');

%%
% save('models/WT.mat', 'mdl');