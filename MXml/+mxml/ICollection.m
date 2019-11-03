classdef (Abstract) ICollection < handle
    % This abstract class can be derived to allow for MXML serializability of list classes.
    % 
    % Author: TADA
    
    methods (Abstract)
        n = length(this)
        b = isempty(this)
        b = any(this, condition)
        s = size(this, dim)
        value = get(this, i)
        set(this, i, value)
        setVector(this, vector)
    end
end

