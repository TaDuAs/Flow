function tf = isPrimitiveValue(value)
    tf = false;

    if isnumeric(value) ||... % numeric values are value type
       ischar(value) ||... % characters are value types
       islogical(value) ||... % booleans are value types
       isstring(value) % strings are value types
        tf = true;
    end
end