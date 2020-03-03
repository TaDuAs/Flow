function item = accessArray(arr, i)
    if iscell(arr)
        item = arr{i};
    elseif isa(arr, 'Simple.IO.MXML.IIterable')
        item = arr.get(i);
    else
        item = arr(i);
    end
end