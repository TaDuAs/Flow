classdef (Abstract) IIterable < lists.ICollection
    % This abstract class can be derived to allow for MXML serializability of list classes.
    % 
    % Author: TADA
    methods
        
        function value = getv(this, i)
            value = this.get(i);
        end
        
        function setv(this, i, value)
            this.set(i, value);
        end
    end
    
    methods (Abstract)
        value = get(this, i);
        set(this, i, value)
    end
end

