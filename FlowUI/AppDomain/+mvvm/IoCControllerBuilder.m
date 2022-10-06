classdef IoCControllerBuilder < mvvm.AppControllerBuilder
    
    properties
        Container IoC.IContainerGetter = IoC.ContainerGetter.empty();
    end
    
    methods
        function this = IoCControllerBuilder(controllerName, iocGetter)
            % send base class just some meaningless function
            this@mvvm.AppControllerBuilder(controllerName, @nan);
            this.Container = iocGetter;
        end
        
        function controller = build(this)
            controller = this.Container.get(this.ControllerName);
        end
        
        function builder = copy(this, app)
            builder = mvvm.IoCControllerBuilder(this.ControllerName, app.IocContainer.get('IoC'));
        end
        
        function this = delete(this)
            this.Container = IoC.ContainerGetter.empty();
            delete@mvvm.AppControllerBuilder(this);
        end
    end
end

