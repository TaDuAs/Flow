classdef DefaultComponentControllerFactory < flow.di.IControllerFactory
    
    properties
        IocContainer IoC.IContainer = IoC.Container.empty();
    end
    
    methods
        function this = DefaultComponentControllerFactory()
            this.IocContainer = IoC.Container();
        end
        
        function controller = create(this, component, parentController, proxyView)
            type = class(component);
            if this.IocContainer.hasDependency(type)
                controller = this.IocContainer.get(type, component, parentController);
            else
                controller = flow.controllers.BoxController(component, parentController);
            end
            
            if isa(controller, 'matlab.ui.internal.componentframework.WebContainerController')
                controller.add(component, parentController);
            end
        end
    end
end

