function [obj, locatedHandle] = setobj(obj, fieldName, value, indexer)
    if nargin < 4 || isempty(indexer); indexer = mvvm.providers.IModelIndexer.empty();
    elseif ~isa(indexer, 'mvvm.providers.IModelIndexer'); throw(MException('mvvm:setobj:invalidIndexer', 'indexer must implement the mvvm.providers.IModelIndexer abstract class')); end
    if isempty(obj)
        obj = struct();
    end
    
    % access the field tree
    if ~iscell(fieldName)
        fieldName = strsplit(fieldName, '.');
    end
    
    currField = fieldName{1};
    if numel(fieldName) > 1
        % try to access the current field in the current object
        el = [];
        if isfield(obj, currField) || isprop(obj, currField)
            el = obj.(currField);
        end
        
        % update up the field path
        [newFieldValue, locatedHandle] = mvvm.setobj(el, fieldName(2:end), value, indexer);
    else
        % recursion termination condition reached
        newFieldValue = value;
        locatedHandle = false;
    end
    
    % when no handles are found up the field path, update the current field
    % to persist the update in the object.
    if isempty(currField)
        if isempty(indexer)
            obj = newFieldValue;
        else
            obj = indexer.setv(obj, newFieldValue);
        end
    elseif ~locatedHandle
        if isempty(indexer)
            obj.(currField) = newFieldValue;
        else
            if isfield(obj, currField) || isprop(obj, currField)
                temp = obj.(currField);
                temp2 = indexer.setv(temp, newFieldValue);
                if ~isa(temp, 'handle')
                    obj.(currField) = temp2;
                end
            end
        end
    end
    
    % if this or any objects up the field path are handles, stop updating
    % doen the field path as the data is already in persistence
    locatedHandle = locatedHandle || isa(obj, 'handle');
end

