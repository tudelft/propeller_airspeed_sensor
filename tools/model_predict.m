function model_predict(mdl_list,test_data,order_str)
    fprintf("------------ Model Comparison Run ------------ \n")
    mdl_fields = fieldnames(mdl_list);
    for j = 1:length(mdl_fields)
        mdl = mdl_list.(mdl_fields{j});
        rpm_order = order_str.("rpm"+mdl_fields{j});
        power_order = order_str.("power"+mdl_fields{j});
        rpmrate_order = order_str.("omega"+mdl_fields{j});
        %Input Creation Block
        fields = fieldnames(test_data);
        for i = 1:length(fields)
            input = [];
            ac_data = test_data.(fields{i});
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

            %Model Prediction and Analysis
            airspeed_pred = predict(mdl, input);
            test_ndata = ac_data.airspeed - (airspeed_pred);
            std_t =sqrt(sum(test_ndata.^2 )/(length(ac_data.airspeed)- length(mdl.CoefficientNames(1,:))));

            fprintf('Standard Deviation: %4.3f m/s for model %1.0f\n', std_t,j);

            %Plotting Block
            
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
    fprintf("------------ Comparison Complete ------------ \n")
end


