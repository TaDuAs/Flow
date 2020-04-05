classdef IoCControllerBuilder < mvvm.AppControllerBuilder
    %IOCCONTROLLERBUILDER Summary of this class goes here
    %   Detailed explanation goes here
    
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
    end
end

