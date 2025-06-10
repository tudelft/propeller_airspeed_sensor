function dispModelInfo(Y_real, Y_pred, names, coeff, intercept)
    fprintf('\n-------------------------------------\n');
    
    MSE = mean((Y_real - Y_pred).^2);
    fprintf('RMSE:  %.2f\n', sqrt(MSE))
    % fprintf('nRMSE: %.2f\n', sqrt(MSE)/std(Y_real))
    fprintf('nRMSE: %.2f\n', sqrt(MSE)/(max(Y_real)-min(Y_real)));

    SSE = sum((Y_real - Y_pred).^2);
    SST = sum((Y_real - mean(Y_real)).^2);
    Rsquared = 1 - SSE/SST;
    % fprintf('R2:    %.2f\n', Rsquared)

    % if nargin == 4 && ~isempty(names) && ~isempty(coeff)
        fprintf('# Selected features and coefficients #\n');
        fprintf('Intercept:\t%.2e\n', intercept);
        nonzeroIdx = find(coeff ~= 0);
        for k = 1:length(nonzeroIdx)
            index = nonzeroIdx(k);
           fprintf('%s:\t%.2e\n', names{index}, coeff(index));
        end
    % end
end