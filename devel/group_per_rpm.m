close all

rpm_targets = [6000, 7000, 8000, 9000];
rpm_margins = [50, 20, 20, 20];  % margin for each corresponding RPM target

hold on
colors = lines(length(rpm_targets));

for i = 1:length(rpm_targets)
    rpm_target = rpm_targets(i);
    margin = rpm_margins(i);  % use individual margin
    
    idx = abs(rpm - rpm_target) <= margin;
    
    Va_i = airspeed(idx);
    P_i = power(idx);
    
    scatter(Va_i, P_i, 20, 'filled', 'MarkerFaceColor', colors(i,:));
end

xlabel('Airspeed V_a [m/s]');
ylabel('Power P [W]');
legend(arrayfun(@(r, m) sprintf('RPM ≈ %d ± %d', r, m), rpm_targets, rpm_margins, 'UniformOutput', false));
title('V_a vs Power for Constant RPM Groups');
grid on
ylim([0 150])
hold off
