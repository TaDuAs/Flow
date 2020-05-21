classdef AppAsyncTask
    %APPASYNCTASK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        key;
        name;
        output;
    end
    
    methods
        function this = AppAsyncTask(key, name, output)
            this.key = key;
            this.name = name;
            this.output = output;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

