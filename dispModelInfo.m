function dispModelInfo(Y_real, Y_pred, names, coeff, intercept)
    MSE = mean((Y_real - Y_pred).^2);
    fprintf('---------------------------------------\n');
    fprintf('RMSE:  %.2f\n', sqrt(MSE))
    fprintf('nRMSE: %.2f\n', sqrt(MSE)/(max(Y_real)-min(Y_real)));

    fprintf('# Selected features and coefficients (Assumed omega in RPM, for rad/sec scale accordingly)#\n');
    fprintf('Intercept: %.2e\n', intercept);
    nonzeroIdx = find(coeff ~= 0);
    for k = 1:length(nonzeroIdx)
        index = nonzeroIdx(k);
       fprintf('%s: %.2e\n', names{index}, coeff(index));
    end
    fprintf('---------------------------------------\n');
end