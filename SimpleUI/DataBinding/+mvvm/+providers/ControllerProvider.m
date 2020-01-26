classdef ControllerProvider < mvvm.providers.IModelProvider
    %CONTROLLERPROVIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        App appd.IApp = appd.App.empty();
        ControllerName;
    end
    
    methods
        function this = ControllerProvider(controllerName, app)
            this.ControllerName = controllerName;
            this.App = app;
        end
        
        % Get controller from application
        function controller = getModel(this)
            controller = this.App.getController(this.ControllerName);
        end
        
        % Not supported
        function setModel(this, model)
            throw(MException('mvvm:providers:ControllerProvider:setModel:NotSupported', 'Setting controller via model provider is not supported'));
        end
    end
end

