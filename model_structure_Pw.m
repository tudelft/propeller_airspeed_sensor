function [X, names] = model_structure_Pw(power, w, w_dot, model_structure)
    
    if strcmp(model_structure, 'bem_reduced')
        X = [w ,...
             power.^(2).*w.^(-5)];
        names = {'w', 'p^2*w^-5'};
    
    elseif strcmp(model_structure, 'bem_reduced_wdot')
        X = [w ,...
             power.^(2).*w.^(-5), ...
             w.*w_dot];
        names = {'w', 'p^2*w^-5', 'w*wdot'};

    else
        error('Unknown model structure: %s', model_structure);
    end
end