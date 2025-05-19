function [Xnew, names_new] = appendFeature(X, feat, names, name)
    Xnew = [X feat];
    names_new = [names name];
end