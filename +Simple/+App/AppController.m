classdef AppController < handle & matlab.mixin.Heterogeneous
    properties (Access=private)
        appInstance = [];
    end
    
    properties (Dependent)
        app Simple.App.App;
    end
    
    methods % Property accessors
        function set.app(this, obj)
            this.app_setter(obj);
        end
        function obj = get.app(this)
            obj = this.app_getter();
        end
    end
    
    methods (Access=protected) % Overidable property accessors
        function app_setter(this, obj)
            this.appInstance = obj;
        end
        function obj = app_getter(this)
            obj = this.appInstance;
        end
    end
    
    methods
        function this = AppController()
            Simple.obsoleteWarning('Simple.App');
        end
        
        function handle = getMethod(this, methodName)
            % getMethod returns a handle of an invoker method to the wanted
            % controller method
            handle = @(params) this.(methodName)(params{:});
        end
        
        function call(this, methodName, params)
            % call function invokes a controller method with no output
            this.invoke(methodName, params, 0);
        end
        
        function out = invoke(this, methodName, params, noutArgs)
            % invoke method invokes a controller method with the name
            % methodName.
            % params are passed to the controller method as input arguments.
            % noutArgs specifies the required number of output arguments,
            % default is the number of output args in that methods
            methodHandle = this.getMethod(methodName);
            if nargin < 4
                noutArgs = this.getControllerMethodDefaultOutArgsNum(methodName);
            end
            
            out = cell(1, noutArgs);
            [out{:}] = methodHandle(params);
        end
        
        function noutArgs = getControllerMethodDefaultOutArgsNum(this, methodName)
            % override in order to improve performance in a less general
            % implementation
            noutArgs = 1;
            
            % inspect class methods
            mc = metaclass(this);
            for i = 1:length(mc.MethodList)
                methodMC = mc.MethodList(i);
                if strcmp(methodMC.Name, methodName)
                    noutArgs = numel(methodMC.OutputNames);
                    return;
                end
            end
        end
    end
end

