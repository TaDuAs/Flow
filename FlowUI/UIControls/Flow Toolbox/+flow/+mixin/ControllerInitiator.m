classdef ControllerInitiator < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This is a mixin parent class for all visual components that are 
    % required to initiate their controller
    %
    % This class provides inversion of control solutions for controller
    % creation
    % To inject new controller implementation, either inject a new
    % controller factory via the 'ControllerFactory' property or set
    % the appropriate dependencies in the factory IoC.Container when using
    % flow.di.DefaultComponentControllerFactory
    % 
    % Author TADA, 2020
    
    properties(Access = 'protected')
        ControllerFactory flow.di.IControllerFactory = flow.di.DefaultComponentControllerFactory.empty();
    end
    
    methods
        function this = ControllerInitiator()
            this.ControllerFactory = flow.di.ControllerFactoryManager.Instance.Factory;
        end
    end
    
    methods (Access = 'public', Hidden = true)
        function controller = createController(this, varargin)
            controller = this.ControllerFactory.create(this, varargin{:});
        end
    end
end
