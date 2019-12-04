classdef ContainerGetter < IoC.IContainerGetter
    % IoC.ContainerGetter wraps the full IoC.IContainer and only exposes
    % the IoC.IContainerGetter interface methods, separating in practice
    % between service generation and service registration that should only 
    % be managed by the application during IoC configuration.
    % This container wrapper is basically a Service Locator, and not a 
    % proper dependency injection service. Use this class only when you
    % must and don't pass it around your application unless you have to.
    % An excellent article by Mark Seemann called
    %   Service Locator is an Anti-Pattern
    %   https://blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern/
    % explains why the Service Locator pattern should be avoided
    % The only situation that comes to mind where you should use this
    % Service Locator is in a factory\when loading objects from config file
    %
    % Use with caution.
    %
    %
    % Author: Tada 2019
    
    properties (GetAccess=private,SetAccess=private)
        IoCContainer IoC.IContainer;
    end
    
    methods
        function this = ContainerGetter(ioc)
            this.IoCContainer = ioc;
        end
        
        function tf = hasDependency(this, serviceId)
            tf = this.IoCContainer.hasDependency(serviceId);
        end
        
        function serviceType = getType(this, serviceId)
            serviceType = this.IoCContainer.getType(this, serviceId);
        end
        
        function service = get(this, serviceId, varargin)
            service = this.IoCContainer.get(serviceId, varargin{:});
        end
    end
end

