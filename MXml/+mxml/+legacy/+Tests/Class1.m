classdef Class1
    %CLASS1 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x;
        y;
        list;
    end
    
    methods
        function this = Class1(x, y, list)
            this.x = x;
            this.y = y;
            if nargin >= 3
                this.list = list;
            else
                this.list = mxml.legacy.Tests.IterableImplForTest();
            end
        end
    end
    
end

