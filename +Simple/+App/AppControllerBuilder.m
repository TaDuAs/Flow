classdef AppControllerBuilder
    % Generates an instance of an AppController using a prebuilt factory
    % method
    
    properties
        controllerName;
        factoryMethod;
    end
    
    methods
        function this = AppControllerBuilder(controllerName, factoryMethod)
            Simple.obsoleteWarning('Simple.App');
            this.factoryMethod = factoryMethod;
            this.controllerName = controllerName;
        end
        
        function controller = build(this)
            controller = this.factoryMethod();
        end
    end
end

