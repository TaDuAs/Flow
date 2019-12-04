classdef AppContext < gen.Cache
    % appd.AppContext holds the context for application domains
    
    properties
        IocContainer IoC.IContainer = IoC.Container.empty();
    end
    
    methods
        function this = AppContext(ioc)
            if nargin < 1; ioc = IoC.Container.empty(); end
            this@gen.Cache();
            this.IocContainer = ioc;
        end
    end
end

