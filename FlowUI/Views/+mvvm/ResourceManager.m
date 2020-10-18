classdef ResourceManager < handle
    %RESOURCEMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Resources struct = struct();
    end
    
    methods
        function obj = ResourceManager(inputArg1,inputArg2)
            %RESOURCEMANAGER Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

