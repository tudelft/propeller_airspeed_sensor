function model_predict(mdl,test_data,rpm_order,power_order,rpmrate_order)
    input = [];
    ac_data = test_data;
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
    figure
    hold on; grid on; zoom on;
    plot(ac_data.timestamp, ac_data.airspeed, '.', MarkerEdgeColor='b', DisplayName="Real data");
    plot(ac_data.timestamp, airspeed_pred, '.', MarkerEdgeColor='r', DisplayName="Interpolated data");
    xlabel('t[sec]');
    ylabel('[m/s]');
    title('Airspeed');
    legend('show');
    hold off;
        
end


