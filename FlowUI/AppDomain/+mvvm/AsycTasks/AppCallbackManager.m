classdef (Abstract) AppCallbackManager < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function waitForAsyncTask(this, task)
            this.doCallback(task);
        end
        
    end
    
    methods (Access=private)
        function handleAsyncTaskCallback(this, task)
            output = fetchOutputs(task.future);
            this.doCallback(task, output);
        end
    end
    
    methods (Abstract)
        doCallback(this, task)
        
        callbackInfo = prepareCallbackInfo(this, task)
    end
end

