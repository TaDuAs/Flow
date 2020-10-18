classdef TestingCallbackManager < AppCallbackManager
    methods
        function doCallback(this, task)
            disp(['Task ' task.name '.' task.key ' executed with output ' toString(task.output)]);
        end
        
        function callbackInfo = prepareCallbackInfo(this, task)
            callbackInfo = [task.name '.' task.key];
        end
    end
end

