classdef (Abstract) ICollection < scol.ICollection
    % This abstract class can be derived to allow for data binding of list classes.
    % 
    % Author: TADA
    
    methods (Abstract)
        b = containsIndex(this, i);
        keySet = keys(this);
    end
    
    events
        collectionChanged;
    end
end

