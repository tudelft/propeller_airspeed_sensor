figure('Name','Cp(Va,n)')
scatter(airspeed_filt(datarange), rpm_filt(datarange)/60, 20, ...
        Cp_filt(datarange), 'filled');
colorbar;
% scatter3(airspeed_filt(datarange), rpm_filt(datarange)/60, Cp_filt(datarange), 'filled');
% xlabel('Va'); ylabel('n (rev/s)'); zlabel('C_p'); grid on;
xlabel('Va [m/s]');
ylabel('n [rps]');
title('Cp(Va,n)');

%%
figure('Name','P(Va,n)')
% scatter(airspeed_filt(datarange), rpm_filt(datarange)/60, 20, ...
%         power(datarange,1), 'filled');
% colorbar;
scatter3(airspeed(datarange), rpm(datarange)/60, power(datarange,1), 'filled');
xlabel('Va'); ylabel('n (rev/s)'); zlabel('P'); grid on;
xlabel('Va [m/s]');
ylabel('n [rps]');
title('P(Va,n)');

%%
figure('Name', 'Va(P,n)');
scatter3(power(datarange,1), rpm(datarange)/60, airspeed(datarange), 'filled');
xlabel('P [W]');
ylabel('n [rps]');
zlabel('Va [m/s]');
title('Va(P,n)');
grid on;

%%
figure('Name','Cp(J)');
hold on; grid on; zoom on;
plot(J_filt(datarange), Cp_filt(datarange), '.');
xlabel('J');
ylabel('Cp');
title('Cp(J)');
hold off;

%%
figure('Name','P(J)');
hold on; grid on; zoom on;
plot(J_filt(datarange), power(datarange,1), '.');
xlabel('J');
ylabel('P');
title('P(J)');
hold off;

%%
figure('Name','Cp(Va,n)')

scatter3(airspeed_filt(datarange), ...
         rpm_filt(datarange)/60, ...
         Cp_filt(datarange), ...
         30, ...                         
         Cp_filt(datarange), ...        
         'filled');

xlabel('Va [m/s]');
ylabel('n [rps]');
zlabel('Cp');
title('Cp(Va,n)');
grid on;
colorbar;

colormap jet; 

%%
figure('Name','P(Va,n)');

scatter3(airspeed_filt(datarange), ...
         rpm_filt(datarange)/60, ...
         power(datarange,1), ...
         30, ...                       
         power(datarange,1), ...         
         'filled');

xlabel('Va [m/s]');
ylabel('n [rps]');
zlabel('P');
title('P(Va,n)');
grid on;
colorbar;

colormap jet; 