%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Puplication style Plotters  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
figure('Name','theta angle')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
plot(t, , '.', 'Color', 'k', 'MarkerSize', 8);
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$P$ [W]', 'FontSize', 14, 'Interpreter', 'latex');
box on;

%%
figure('Name','P(J)');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
plot(J(:), power(:), '.', 'Color', 'k', 'MarkerSize', 8);
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$P$ [W]', 'FontSize', 14, 'Interpreter', 'latex');
box on;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:P-vs-J.eps');

%%
figure('Name','Cp(J)');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
plot(J(:), Cp(:), '.', 'Color', 'k', 'MarkerSize', 4);
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
box on;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:Cp-vs-J.eps');

%%
figure('Name','dCp/dJ');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
plot(J(:), dCp_dJ(:), '.', 'Color', 'k', 'MarkerSize', 4);
xlabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$\frac{\mathrm{d}C_P}{\mathrm{d}J}$', 'FontSize', 14, 'Interpreter', 'latex');
box on;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:dCpdJ.eps');

%%
figure('Name','J(Cp)');
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
plot(Cp(:), J(:), '.', 'Color', 'k', 'MarkerSize', 4);
xlabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$J$', 'FontSize', 14, 'Interpreter', 'latex');
box on;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:J-vs-Cp.eps');

%%
figure('Name','Cp(Va,w)')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
scatter3(airspeed(:), rpm(:), Cp(:), 20, Cp(:), 'filled');
xlabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$\omega$ [rpm]', 'FontSize', 14, 'Interpreter', 'latex');
zlabel('$C_P$', 'FontSize', 14, 'Interpreter', 'latex');
box on;
colormap parula;
colorbar;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:Cp-vs-Va+w.eps');

%%
figure('Name','P(Va,w)')
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
scatter3(airspeed(:), rpm(:), power(:), 20, power(:), 'filled');
xlabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$\omega$ [rpm]', 'FontSize', 14, 'Interpreter', 'latex');
zlabel('$P$ [W]', 'FontSize', 14, 'Interpreter', 'latex');
box on;
colormap parula;
colorbar;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:P-vs-Va+w.eps');

%%
figure('Name','P(Va)')
hold on;
ax = gca;
set(ax, 'FontSize', 14, 'LineWidth', 1.2);
set(ax, 'TickLabelInterpreter', 'latex');
plot(Va(:), P(:,20) , '.', 'MarkerSize', 10, DisplayName='2000 RPM');
plot(Va(:), P(:,40) , '.', 'MarkerSize', 10, DisplayName='4000 RPM');
plot(Va(:), P(:,60) , '.', 'MarkerSize', 10, DisplayName='6000 RPM');
plot(Va(:), P(:,80) , '.', 'MarkerSize', 10, DisplayName='8000 RPM');
plot(Va(:), P(:,100) , '.', 'MarkerSize', 10, DisplayName='10000 RPM');
xlabel('$V_a$ [m/s]', 'FontSize', 14, 'Interpreter', 'latex');
ylabel('$P$ [W]', 'FontSize', 14, 'Interpreter', 'latex');
hold off;

legend boxoff;

% set(gcf, 'Renderer', 'painters');  
% print('-depsc', '/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/bem:P-vs-Va_wconst.eps');