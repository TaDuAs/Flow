classdef ContainerDependency < IoC.Dependency
    methods
        function this = ContainerDependency(ioc, id)
            this@IoC.Dependency(ioc, id, @() IoC.ContainerGetter(ioc));
        end
    end
    
    methods (Access=protected)
        function new = doDuplicateFor(this, ioc)
            new = IoC.ContainerDependency(ioc, this.Id);
        end
    end
end

