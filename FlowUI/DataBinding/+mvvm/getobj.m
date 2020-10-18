function [value, foundField] = getobj(obj, fieldName, defaultValue, warnNotFound)
    if nargin < 1
        throw(MException('mvvm:getobj:Obj_Missing', 'obj must be specified'));
    elseif nargin < 2
        throw(MException('mvvm:getobj:FieldName_Missing', 'fieldName must be specified'));
    elseif (~iscellstr(fieldName) && ~ischar(fieldName))
        throw(MException('mvvm:getobj:FieldName_Invalid', 'fieldName must be a char vector of values separated by ''.'' or a cell array of char vectors representing the field names'));
    elseif (iscell(fieldName) && numel(fieldName) > 1 && any(cellfun(@isempty, fieldName))) || (ischar(fieldName) && any(strfind(fieldName, '..')))
        if iscell(fieldName); fieldName = strjoin(fieldName, '.'); end
        throw(MException('mvvm:getobj:EmptyField', 'The field path contains empty field names. FieldPath: %s', fieldName));
    elseif nargin < 4
        warnNotFound = true;
    elseif ischar(warnNotFound) && isrow(warnNotFound) && strcmpi(warnNotFound, 'nowarn')
        warnNotFound = false;
    elseif ~isscalar(warnNotFound) || ~islogical(warnNotFound)
        throw(MException('mvvm:getobj:WarnNotFound_Invalid', 'warnNotFound must be a logical scalar'));
    end
    
    foundField = true;
    % prep field tree
    if isempty(fieldName) || (numel(fieldName) == 1 && strcmp(fieldName, ''))
        fieldName = {};
    elseif ~iscell(fieldName)
        fieldName = strsplit(fieldName, '.');
    end
    element = obj;

    % access the field tree
    for i = 1:length(fieldName)
        currField = fieldName{i};
        if isempty(element)
            foundField = false;
            break;
        elseif ~hasField(element, currField)
            foundField = false;
            element = [];
            if warnNotFound
                warning('mvvm:getobj:fieldPathNotFound', 'Field path at ''%s'' not found', strjoin(fieldName, '.'));
            end
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

function l = hasField(element, field)
    l = (istable(element) && ismember(field, element.Properties.VariableNames)) ||...
         isfield(element, field) || isprop(element, field);
end

