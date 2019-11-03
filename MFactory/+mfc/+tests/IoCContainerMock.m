classdef IoCContainerMock < IoC.IContainerGetter
    properties
        dep = struct();
    end
    
    methods
        function this = IoCContainerMock(dep)
            if nargin >= 1
                this.dep = dep;
            end
        end
        
        function serviceType = getType(this, serviceId)
            if isfield(this.dep, serviceId)
                serviceType = class(this.dep.(serviceId));
            else
                error('service id %s missing', serviceId);
            end
        end
        
        function service = get(this, serviceId, varargin)
            if isfield(this.dep, serviceId)
                service = this.dep.(serviceId);
            else
                error('service id %s missing', serviceId);
            end
        end
        
        function tf = hasDependency(this, serviceId)
            tf = isfield(this.dep, serviceId);
        end
    end
end

