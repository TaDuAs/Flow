classdef (Abstract) ICollection < handle
    % This abstract class can be derived to allow for MXML serializability of list classes.
    % 
    % Author: TADA
    
    methods (Abstract)
        n = length(this)
        b = isempty(this)
        s = size(this, dim)
        value = getv(this, i)
        setv(this, i, value)
        add(this, value)
        removeAt(this, i)
        setVector(this, vector)
    end
end

