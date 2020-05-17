classdef IControllerFactory < handle
    methods (Abstract)
        controller = create(factory, component, parent);
    end
end

