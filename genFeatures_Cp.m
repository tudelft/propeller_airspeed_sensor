function [X, termNames] = genFeatures_Cp(Cp, iRange)
    % Ensure column vectors
    Cp = Cp(:);
    
    % Small epsilon to avoid division by zero
    epsVal = 1e-8;
    
    termNames = {};
    X = [];
    
    for i = iRange
        if i == 0
            continue; 
        end
        
        termLabel = sprintf('Cp^%d', i);
        termNames{end+1} = termLabel;
        
        Cpi = Cp.^abs(i); if i < 0, Cpi = 1 ./ (Cpi + epsVal); end        
        X(:, end+1) = Cpi;
    end
end