function [X, termNames] = genFeatures_Pw(power, w, iRange, jRange)
    % Ensure column vectors
    power = power(:);
    w = w(:);
    
    % Small epsilon to avoid division by zero
    epsVal = 1e-8;
    
    termNames = {};
    X = [];
    
    for i = iRange
        for j = jRange
            if i == 0 && j == 0
                continue; 
            end
            
            termLabel = sprintf('P^%d*w^%d', i, j);
            termNames{end+1} = termLabel;
            
            Pi = power.^abs(i); if i < 0, Pi = 1 ./ (Pi + epsVal); end
            Wj = w.^abs(j);   if j < 0, Wj = 1 ./ (Wj + epsVal); end
            
            X(:, end+1) = Pi .* Wj;
        end
    end
end