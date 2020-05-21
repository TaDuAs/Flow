function value = accessarr(arr, i, setValue)
            Simple.obsoleteWarning();
    import Simple.*;
    % Setter
    if nargin > 2
        if iscell(arr)
            arr{i} = setValue;
        elseif isa(arr, 'Simple.IO.MXML.IIterable')
            arr.set(i, setValue);
        else
            arr(i) = setValue;
        end
        
        if nargout > 0
            value = setValue;
        end
        
    % Getter
    else
        if iscell(arr)
            value = arr{i};
        elseif isa(arr, 'Simple.IO.MXML.IIterable')
            value = arr.get(i);
        else
            value = arr(i);
        end
    end
end

