function mdl = linear_model_fitter (train_data,rpm_order,power_order,rpmrate_order)
    input = [];
   
    ac_data = train_data;
    
    %Inlude Merge Function to merge all listed data sets
    for k = rpm_order
        input(1:length(ac_data.rpm),end+1) = ac_data.rpm.^k;
    end
    for k = power_order
        input(1:length(ac_data.rpm),end+1) = ac_data.power.^k;
    end
    for k = rpmrate_order
        input(1:length(ac_data.rpm),end+1) = ac_data.rpmrate.^k;
    end
    input(1:length(ac_data.power),end+1) = ac_data.power .* ac_data.rpm;
    input(1:length(ac_data.dshot),end+1) = ac_data.dshot;
    input(1:length(ac_data.dshotrate),end+1) = ac_data.dshotrate;
    
    output = ac_data.airspeed;
    mdl = fitlm(input, output, "linear", 'Intercept', true);
    

    fprintf('R^2: %.2f\n', mdl.Rsquared.Ordinary);
    fprintf('Coeff: '); fprintf('%.8f ', mdl.Coefficients.Estimate); fprintf("\n");

    figure('Name','Airspeed model fit');
    tiledlayout(3, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
    
    ax1 = nexttile([3, 1]);
    hold on; grid on; zoom on;
    plot(ac_data.timestamp, output, '.', MarkerEdgeColor='b', DisplayName="Real data");
    plot(ac_data.timestamp, mdl.Fitted, '.', MarkerEdgeColor='r', DisplayName="Interpolated data");
    xlabel('t[sec]');
    ylabel('V[m/s]');
    title('Airspeed');
    legend('show');
    hold off;
    
    ax2 = nexttile;
    hold on; grid on; zoom on;
    plot(ac_data.timestamp, ac_data.rpm, '.', DisplayName="rpm", LineWidth=1.5);
    xlabel('t[sec]');
    ylabel('RPM');
    title('RPM');
    legend('show');
    hold off;
    
    ax3 = nexttile;
    hold on; grid on; zoom on;
    plot(ac_data.timestamp, ac_data.power, '.', DisplayName="power", LineWidth=1.5);
    xlabel('t[sec]');
    ylabel('Power[Watt]');
    title('Power');
    legend('show');
    hold off;
    
    ax4 = nexttile;
    hold on; grid on; zoom on;
    plot(ac_data.timestamp, ac_data.rpmrate, '.', DisplayName="rpm dot", LineWidth=1.5);
    xlabel('t[sec]');
    ylabel('RPM Rate [rpm/s]');
    title('RPM Rate');
    legend('show');
    hold off;
    
    linkaxes([ax1,ax2,ax3,ax4],'x');
end