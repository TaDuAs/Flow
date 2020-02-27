classdef DependencyFetcher < handle
    properties
        IoCContainer IoC.IContainerGetter = IoC.ContainerGetter.empty();
        Dependency string;
    end
    
    methods
        function this = DependencyFetcher(ioc, dependency)
            this.IoCContainer = ioc;
            this.Dependency = dependency;
        end
        
        function dep = fetch(this)
            dep = this.IoCContainer.get(this.Dependency);
        end
    end
end

