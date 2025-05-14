function dispModelInfo(FitInfo, names, coeff, idx)
    fprintf('\n-------------------------------------\n');
    fprintf('Cross-validated MSE: %.3f\n', FitInfo.MSE(idx))
    fprintf('Selected features and coefficients:\n');

    nonzeroIdx = find(coeff ~= 0);
    for k = 1:length(nonzeroIdx)
        idx = nonzeroIdx(k);
        fprintf('%s:\t%.25f\n', names{idx}, coeff(idx));
    end
end