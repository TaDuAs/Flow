classdef (Abstract) IQueueFactory < handle
    methods (Abstract)
        % Builds a data queue using input
        queue = build(factory, varargin);
    end
end

