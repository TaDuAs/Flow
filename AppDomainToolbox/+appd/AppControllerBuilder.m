classdef AppControllerBuilder
    % Generates an instance of an AppController using a prebuilt factory
    % method
    
    properties
        ControllerName string;
        FactoryMethod function_handle;
    end
    
    methods
        function this = AppControllerBuilder(controllerName, factoryMethod)
            this.FactoryMethod = factoryMethod;
            this.ControllerName = string(controllerName);
        end
        
        function controller = build(this)
            controller = this.FactoryMethod();
        end
    end
end

