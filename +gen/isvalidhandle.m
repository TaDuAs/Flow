function tf = isvalidhandle(obj)
    if isa(obj, 'handle')
        tf = isvalid(obj);
    else
        tf = false(size(obj));
    end
end

