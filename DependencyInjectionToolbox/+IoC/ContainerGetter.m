classdef ContainerGetter < IoC.IContainerGetter
    
    properties (GetAccess=private,SetAccess=private)
        IoCContainer IoC.Container;
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

