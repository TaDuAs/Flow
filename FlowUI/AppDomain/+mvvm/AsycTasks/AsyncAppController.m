classdef AsyncAppController < AppController% & dynamicprops
    % AsyncAppController is a decorator class adding asynchronous
    % computing to each API invocation
    
    properties
        controller;
        key;
    end
    
    methods (Access=protected) % Overidable property accessors
        function app_setter(this, obj)
            this.controller.app = obj;
        end
        function obj = app_getter(this)
            obj = this.controller.app;
        end
    end
    
    methods
        function this = AsyncAppController(controller, key)
            this.controller = controller;
            this.key = key;
        end
        
        function handle = getMethod(this, methodName)
            % Call original controller's method
            handle = this.controller.getMethod(methodName);
        end
        
        function out = invoke(this, methodName, params, noutArgs)
            % invoke method invokes a controller method with the name
            % methodName.
            % params are passed to the controller method as input arguments.
            % noutArgs specifies the required number of output arguments,
            % default is 1
            methodHandle = this.getMethod(methodName);
            
            if nargin < 4
                noutArgs = this.getControllerMethodDefaultOutArgsNum(methodHandle);
            end
            
            % Invoke asynchronously
            methodHandle = this.wrapAsyncMethod(methodHandle, methodName, noutArgs);
            
            f = methodHandle(params);
            out = [];
        end
        
        function noutArgs = getControllerMethodDefaultOutArgsNum(this, handle)
            % Call original controller's method
            noutArgs = this.controller.getControllerMethodDefaultOutArgsNum(handle);
        end
        
        function wrappedMethodHandle = wrapAsyncMethod(this, methodHandle, methodName, noutArgs)
            % returns an asynchronous function calling the method handle
            % and executing "doCallback" of application's callback manager
            
            function asyncDoCallback(params)
                App.startInWorkerProcess(this.app);
                
                out = cell(1, noutArgs);
                [out{:}] = methodHandle(params);
                
                this.app.callbackManager.waitForAsyncTask(AppAsyncTask(this.key, methodName, out));
            end
            
            wrappedMethodHandle = @(params) parfeval(@asyncDoCallback, 0, params);
        end
    end
end

