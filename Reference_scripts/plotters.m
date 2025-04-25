figure('Name','Cp(Va,n)')
h = scatter3(airspeed(:), rpm(:)/60, Cp(:), [], Cp(:), 'filled');
xlabel('Va [m/s]');
ylabel('omega [rpm]');
zlabel('Cp');
title('Cp(Va,omega)');
grid on;

colormap jet;
colorbar;

%%
figure('Name','P(Va,omega)')
h = scatter3(airspeed(:), rpm(:)/60, power(:,1), [], power(:,1), 'filled');
xlabel('Va [m/s]');
ylabel('omega [rpm]');
zlabel('P [W]');
title('P(Va,omega)');
grid on;

colormap bone;
colorbar;

%%
figure('Name', 'Va(P,omega)');
h = scatter3(power(:,1), rpm(:)/60, airspeed(:), [], airspeed(:), 'filled');
xlabel('P [W]');
ylabel('omega [rpm]');
zlabel('Va [m/s]');
title('Va(P,omega)');
grid on;

colormap bone;
colorbar;

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