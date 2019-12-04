function tf = isSameSetAs(arr1, arr2)
    if numel(arr1) ~= numel(arr2)
        tf = false;
        return;
    end

    tf = true;
    
    for curr1 = arr1
        didFind = false;
        
        if iscell(curr1)
           curr1 = curr1{1};
        end
        
        for curr2 = arr2
            if iscell(curr2)
               curr2 = curr2{1};
            end
            
            if isequal(curr1, curr2)
                didFind = true;
                break;
            end
        end
        
        if ~didFind
            tf = false;
            return;
        end
    end
end

