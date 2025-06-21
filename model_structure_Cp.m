function [X, names] = model_structure_Cp(Cp, model_structure)
    if strcmp(model_structure, 'bem')
        X = [Cp Cp.^4];
        names = {'Cp', 'Cp^4'};
    else
        error('Unknown model structure: %s', model_structure);
    end
end