function value = getobj(obj, fieldName, defaultValue)
    import Simple.*;

    % access the field tree
    if isempty(fieldName)
        fieldName = {};
    elseif ~iscell(fieldName)
        fieldName = strsplit(fieldName, '.');
    end
    element = obj;

    for i = 1:length(fieldName)
        currField = fieldName{i};
        if ~isfield(element, currField) && ~any(isprop(element, currField))
            element = [];
            break;
        end
        element = element.(currField);
    end
    
    if isempty(element) && nargin >= 3
        value = defaultValue;
    else
        value = element;
    end
end

