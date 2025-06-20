function [X, names] = model_structure_Pw(power, rpm, rpm_dot, model_structure)
    
    if strcmp(model_structure, 'bem_reduced')
        X = [rpm ,...
             power.^(2).*rpm.^(-5)];
        names = {'w', 'p^2*w^-5'};
    
    elseif strcmp(model_structure, 'bem_reduced_wdot')
        X = [rpm ,...
             power.^(2).*rpm.^(-5), ...
             rpm.*rpm_dot];
        names = {'w', 'p^2*w^-5', 'w*wdot'};

    else
        error('Unknown model structure: %s', model_structure);
    end
end