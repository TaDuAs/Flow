classdef DependencyFetcher < IoC.IDependencyFetcher
    properties
        IocContainer IoC.IContainerGetter = IoC.ContainerGetter.empty();
        Dependency string;
    end
    
    methods
        function this = DependencyFetcher(ioc, dependency)
            this.IocContainer = ioc;
            this.Dependency = dependency;
        end
        
        function dep = fetch(this)
            dep = this.IocContainer.get(this.Dependency);
        end
    end
end

