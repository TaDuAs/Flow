classdef ControllerFactoryManager
    %CONTROLLERFACTORYMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        Instance = flow.di.ControllerFactoryManager();
    end
    
    properties
        Factory flow.di.IControllerFactory = flow.di.DefaultComponentControllerFactory.empty();
    end
    
    methods
        function this = ControllerFactoryManager()
            this.Factory = flow.di.DefaultComponentControllerFactory();
        end
    end
end

