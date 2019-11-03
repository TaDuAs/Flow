classdef (Abstract) IContainerGetter < handle
    methods (Abstract)
        serviceType = getType(this, serviceId);
        service = get(this, serviceId, varargin);
        tf = hasDependency(this, serviceId);
    end
end

