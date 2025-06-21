function [X, names] = model_structure_Pw(power, w, wdot, model_structure)  
    if strcmp(model_structure, 'bem_reduced')
        X = [w ,...
             power.^(2).*w.^(-5)];
        names = {'w', 'p^2*w^-5'};
    else
        error('Unknown model structure: %s', model_structure);
    end
end