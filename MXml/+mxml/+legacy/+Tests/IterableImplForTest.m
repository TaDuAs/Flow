classdef IterableImplForTest < Simple.IO.MXML.IIterable & handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        arr;
    end
    
    methods
        function this = IterableImplForTest()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            this.arr = [];
        end
        
        function n = length(this)
            n = length(this.arr);
        end
        function b = isempty(this)
            b = isempty(this.arr);
        end
        function b = any(this)
            b = any(this.arr);
        end
        function s = size(this, dim)
            if nargin < 2
                s = size(this.arr);
            else
                s = size(this.arr, dim);
            end
        end
        function value = get(this, i)
            value = this.arr(i);
        end
        function set(this, i, value)
            this.arr(i) = value;
        end
        
        function setVector(this, vector)
            this.arr = vector;
        end
    end
end

