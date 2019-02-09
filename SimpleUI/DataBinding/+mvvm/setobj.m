function [obj, locatedHandle] = setobj(obj, fieldName, value)
    % access the field tree
    if ~iscell(fieldName)
        fieldName = strsplit(fieldName, '.');
    end
    
    currField = fieldName{1};
    if length(fieldName) > 1
        % try to access the current field in the current object
        el = [];
        if isfield(obj, currField) || isprop(obj, currField)
            el = obj.(currField);
        end
        
        % update up the field path
        [newFieldValue, locatedHandle] = mvvm.setobj(el, fieldName(2:end), value);
    else
        % recursion termination condition reached
        newFieldValue = value;
        locatedHandle = false;
    end
    
    % when no handles are found up the field path, update the current field
    % to persist the update in the object.
    if ~locatedHandle
        obj.(currField) = newFieldValue;
    end
    
    % if this or any objects up the field path are handles, stop updating
    % doen the field path as the data is already in persistence
    locatedHandle = locatedHandle || isa(obj, 'handle');
end

