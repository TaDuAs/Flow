function obj = parsejsonElement(element)
    if iscellstr(element)
        if size(element, 1) > 1 && size(element, 2) == 1
            obj = element';
        else
            obj = element;
        end
    elseif isstruct(element) && isfield(element, 'isList') && element.isList
        n = length(element.value);
        obj = createList(element.type, n);
        for i = 1:n
            inner = mxml.legacy.private.parsejsonElement(accessArray(element.value, i));
            if iscell(obj)
                obj{i} = inner;
            elseif isa(obj, 'mxml.legacy.IIterable')
                if obj.isempty()
                    obj.setVector(inner);
                else
                    obj.set(i, inner);
                end
            else
                obj(i) = inner;
            end
        end
    elseif isstruct(element)
        copyto = struct;
        
        if isfield(element, 'type')
            copyfrom = element.value;
            type = element.type;
        else
            type = 'struct';
            copyfrom = element;
        end
        
        if mxml.legacy.private.isPrimitiveValueType(copyfrom)
            % this basicly means this is an enum
            copyto = copyfrom;
        else
            % Parse child fields recursively
            jsonFields = fieldnames(copyfrom);
            for fieldIdx = 1:length(jsonFields)
                copyto.(jsonFields{fieldIdx}) = mxml.legacy.private.parsejsonElement(copyfrom.(jsonFields{fieldIdx}));
            end
        end
        
        % generate instance if necessary
        if strcmp(type, 'struct')
            obj = copyto;
        else
            obj = MXML.Factory.instance.construct(type, copyto);
        end
    elseif mxml.legacy.private.isPrimitiveValueType(element)
        % primitive types
        if size(element, 1) > 1 && size(element, 2) == 1
            obj = element';
        else
            obj = element;
        end
    else
        obj = element;
    end
end
function list = createList(type, n)
    if strcmp(type, 'cell')
        list = cell(1, n);
    elseif any(strcmp(superclasses(type), 'MXML.IIterable'))
        list = MXML.Factory.instance.construct(type);
    else
        temp = mxml.legacy.Factory.instance.cunstructEmpty(type);
        list = repmat(temp, 1, n);
    end
end
