[airspeed_unique, ~] = unique(airspeed);
[rpm_unique, ~] = unique(rpm);
[rpm_grid, airspeed_grid] = meshgrid(rpm_unique, airspeed_unique);
Cp_grid = griddata(rpm, airspeed, Cp, rpm_grid, airspeed_grid, 'linear');

figure;
surf(airspeed_grid, rpm_grid, Cp_grid, 'EdgeColor', 'none');
xlabel('Airspeed (m/s)');
ylabel('RPM');
zlabel('Cp');
title('Cp as a function of Airspeed and RPM');
colormap winter;
colorbar;

[pCp_airspeed, pCp_rpm] = gradient(Cp_grid);
gradient_magn = sqrt(pCp_rpm.^2 + pCp_airspeed.^2);
% pcolor(airspeed_grid, rpm_grid, gradient_magn);
% quiver(airspeed_grid, rpm_grid, pCp_airspeed, pCp_rpm, 'LineWidth', 1);

hold on;

mask = gradient_magn < 0.00003;
x_black = airspeed_grid(mask);
y_black = rpm_grid(mask);
z_black = Cp_grid(mask);

scatter3(x_black, y_black, z_black, 20, 'k', 'filled');
hold off;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Puplication style Plotters  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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