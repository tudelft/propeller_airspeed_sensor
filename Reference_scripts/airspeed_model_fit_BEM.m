% clear; 
% close all;

t = 1:1:4854;
J = airspeed./((rpm/60)*(10*0.0254));
Cp = power./(1.225*(10*0.0254)^5*(rpm/60).^3);

%%
% datarange = J>0.3 & airspeed>=5 & power>30;
datarange = J > 0.25;

% %% Fitting for power
% input = [J(datarange) J(datarange).^2];
% output = Cp(datarange);
% 
% mdl_power = fitlm(input, output, "linear", 'Intercept', true);
% 
% fprintf('R^2: %.2f\n', mdl_power.Rsquared.Ordinary);
% fprintf('Coeff: '); fprintf('%.8f ', mdl_power.Coefficients.Estimate); fprintf("\n");
% 
% figure('Name','Cp fit');
% hold on; grid on; zoom on;
% plot(J(datarange), output, '.', MarkerEdgeColor='b', DisplayName="Real");
% plot(J(datarange), mdl_power.Fitted, '.', MarkerEdgeColor='r', DisplayName="Predicted");
% xlabel('J');
% ylabel('Cp');
% title('Cp(J)');
% legend('show');
% hold off;
% 
% %% Invert to find airspeed
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

%% fitting
input = [power(datarange) rpm(datarange), ...
         power(datarange).^2 rpm(datarange).^2, ...
         power(datarange).*rpm(datarange)];

output = airspeed(datarange);

mdl = fitlm(input, output, "linear", 'Intercept', true);

%% plotting
fprintf('R^2: %.2f\n', mdl.Rsquared.Ordinary);
fprintf('Coeff: '); fprintf('%.8f ', mdl.Coefficients.Estimate); fprintf("\n");

figure('Name','Airspeed model fit');
tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

ax1 = nexttile([2, 1]);
hold on; grid on; zoom on;
plot(t(datarange), output, '.', MarkerEdgeColor='b', MarkerSize=10, DisplayName="Real data");
plot(t(datarange), mdl.Fitted, '.', MarkerEdgeColor='r', MarkerSize=10, DisplayName="Interpolated data");
xlabel('t[sec]');
ylabel('[m/s]');
title('Airspeed');
legend('show');
hold off;

ax2 = nexttile;
hold on; grid on; zoom on;
plot(t(datarange), rpm(datarange), '.', DisplayName="rpm", LineWidth=1.5);
xlabel('t[sec]');
ylabel('[rpm]');
title('rpm');
legend('show');
hold off;

ax3 = nexttile;
hold on; grid on; zoom on;
plot(t(datarange), power(datarange), '.', DisplayName="power", LineWidth=1.5);
xlabel('t[sec]');
ylabel('[Watt]');
title('power');
legend('show');
hold off;

linkaxes([ax1,ax2,ax3],'x');

%%
% save('models/WT.mat', 'mdl');