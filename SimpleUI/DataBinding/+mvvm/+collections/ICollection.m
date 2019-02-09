classdef (Abstract) ICollection < handle
    % This abstract class can be derived to allow for data binding of list classes.
    % 
    % Author: TADA
    
    methods (Abstract)
        n = length(this);
        b = isempty(this);
        s = size(this, dim);
        value = getv(this, i);
        setv(this, value, i);
        removeAt(this, i);
        b = containsIndex(this, i);
        keySet = keys(this);
    end
    
    events
        collectionChanged;
    end
end

