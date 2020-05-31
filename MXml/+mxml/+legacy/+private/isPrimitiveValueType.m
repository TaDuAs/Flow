function isValueType = isPrimitiveValueType(value)
    isValueType = false;
    
    if isnumeric(value) ||... % numeric values are value type
       ischar(value) ||... % strings are value types
       islogical(value) % booleans are value types
        isValueType = true;
    end
end