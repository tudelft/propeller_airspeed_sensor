function model_predict(mdl,test_data,rpm_order,power_order,rpmrate_order)
    
    fields = fieldnames(test_data);
    for i = 1:length(fields)
        input = [];
        ac_data = test_data.(fields{i});
        for k = 1:rpm_order
            input(1:length(ac_data.rpm),end+1) = ac_data.rpm.^k;
        end
        for k = 1:power_order
            input(1:length(ac_data.rpm),end+1) = ac_data.power.^k;
        end
        for k = 1:rpmrate_order
            input(1:length(ac_data.rpm),end+1) = ac_data.rpmrate.^k;
        end
        input(1:length(ac_data.dshot),end+1) = ac_data.dshot;
        input(1:length(ac_data.dshotrate),end+1) = ac_data.dshotrate;
    
        airspeed_pred = predict(mdl, input);
    
        test_ndata = ac_data.airspeed - (airspeed_pred);
        std_t =sqrt(sum(test_ndata.^2 )/(length(ac_data.airspeed)- length(mdl.CoefficientNames(1,:))));
        fprintf('Standard Deviation: %.2f\n', std_t);
        
        figure('Name',['Airspeed model Prediction: ' (fields{i})]);
        tiledlayout(3, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
    
        ax1 = nexttile([3, 1]);
        hold on; grid on; zoom on;
        plot(ac_data.timestamp, ac_data.airspeed, '.', MarkerEdgeColor='b', DisplayName="Real data");
        plot(ac_data.timestamp, airspeed_pred, '.', MarkerEdgeColor='r', DisplayName="Interpolated data");
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
        title('Rotations per minute ');
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
        ylabel('RPM Rate[rpm/s]');
        title('Angular Acceleration');
        legend('show');
        hold off;
        
        linkaxes([ax1,ax2,ax3,ax4],'x');
    end
        
end


