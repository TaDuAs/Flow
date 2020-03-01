classdef ContainerDependency < IoC.Dependency
    methods
        function this = ContainerDependency(ioc, id)
            this@IoC.Dependency(ioc, id, @() IoC.ContainerGetter(ioc));
        end
    end
    
    methods (Access=protected)
        function new = generateCopyInstance(this, ioc)
            new = IoC.ContainerDependency(ioc, this.Id);
        end
    end
end

