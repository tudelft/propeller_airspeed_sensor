function dispModelInfo(Y_real, Y_pred, names, coeff, intercept)
    MSE = mean((Y_real - Y_pred).^2);
    RMSE = sqrt(MSE);
    nRMSE = sqrt(MSE)/(max(Y_real)-min(Y_real));

    fprintf('---------------------------------------\n');
    
    fprintf('RMSE:  %.2f\n', RMSE);
    fprintf('nRMSE: %.3f\n', nRMSE);

    fprintf('# Selected features and coefficients\n');
    fprintf('Intercept: %.2e\n', intercept);
    nonzeroIdx = find(coeff ~= 0);
    for k = 1:length(nonzeroIdx)
        index = nonzeroIdx(k);
       fprintf('%s: %.2e\n', names{index}, coeff(index));
    end
end