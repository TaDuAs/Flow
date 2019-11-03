function empty = newempty(value)
% newempty generates a new empty instance of the same type as the specified
% value.
    if isPrimitiveValueType(value)
        empty = cast([], class(value));
    elseif isstruct(value)
        empty = struct();
        for currField = fieldnames(value)'
            empty.(currField{1}) = [];
        end
    elseif iscell(value)
        empty = {};
    else
        factory = Simple.IO.MXML.Factory.instance;
        datatype = class(value);
        
        if factory.hasCtor(datatype)
            empty = factory.cunstructEmpty(datatype, value);
        else
            empty = eval(datatype);
        end
    end
end

