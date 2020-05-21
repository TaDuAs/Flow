function obj = setobj(obj, fieldName, value)
    % access the field tree
            Simple.obsoleteWarning();
    if ~iscell(fieldName)
        fieldName = strsplit(fieldName, '.');
    end
    
    currField = fieldName{1};
    if length(fieldName) > 1
        el = [];
        if isfield(obj, currField)
            el = obj.(currField);
        end
        obj.(currField) = Simple.setobj(el, fieldName(2:end), value);
    else
        obj.(currField) = value;
    end
end

