classdef (Abstract) IControl < handle
    % List of methods a ui control should implement in order to be data
    % bound using mvvm toolbox
    
    methods (Abstract)
        parent = ancestor(this, type);
    end
end

