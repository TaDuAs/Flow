function element = jsonize(obj)
% jsonize prepares the object graph to reversible json serialization
% The regular object graph will be stripped of data-types once serialized
% to JSON format.
% In this implementation primitive types such as numerics, logicals,
% char-arrays, do not recieve the added typing convention to minimize the
% object graph and the json size. This however removes the type
% reversibility of these types, i.e, int and double are treated similarly
% thus when parsing back from json, int32 types will be parsed into double
% and so on.
%
% for instance:
% a = struct('id', '', 'children', struct('name', {'a', 'b'}, 'value', {1, 2}), 'class', someClassDef)
% 
% jsonizes into the following object graph:
% a = struct('id', ''),...
%            'children', struct('type', 'struct', 'isList', true, 'value', [struct('name', 'a', 'value', 1), struct('name', 'b', 'value', 2)],...
%            'class', struct('type', 'someClassDef', 'value', struct(all properties of someClassDef))
%
% which in turn is encoded into this json:
% { "id":"",
%   "children":{"type":"struct", "isList":true, "value":[{"name":"a", "value":1}, 
%                                                        {"name":"b", "value":2}]},
%   "class":{"type":"someClassDef", "value":{"prop1":value1,"prop2":value2,...}} }

    % validate valid datatypes
    if istable(obj) || isa(obj, 'containers.Map')
        error('tables and maps are not supported by this function yet... if your getting this, better implement it quick!');
    end
    
    % If obj is a number or a string or some other primitive value type
    if isenum(obj)
        if length(obj) > 1
            element = struct('type', class(obj), 'isList', true, 'value', {arrayfun(@(a) char(a), obj, 'UniformOutput', false)});
        else
            element = struct('type', class(obj), 'value', char(obj));
        end
    elseif mxml.legacy.private.isPrimitiveValueType(obj) || iscellstr(obj) 
        element = obj;
        return;
    % if obj is an array of reference types or structs
    elseif (isvector(obj) && length(obj) > 1) || iscell(obj) || isa(obj, 'mxml.legacy.IIterable')
        arraySize = length(obj);
        element = struct('type', class(obj), 'isList', true, 'value', {cell(1, arraySize)});
        for i = 1:arraySize
            element.value{i} = mxml.legacy.private.jsonize(mxml.legacy.private.accessArray(obj, i));
        end
    % handle ref types and structs
    elseif ~isempty(obj)
        fields = fieldnames(obj);
        element = struct('type', class(obj), 'value', struct());
        
        % Append all properties
        for i = 1:length(fields)
            currFieldName = fields{i};
            fieldValue = obj.(currFieldName);
            currFieldElement = mxml.legacy.private.jsonize(fieldValue);
            element.value.(currFieldName) = currFieldElement;
        end
    end
end