classdef IterableImplForTest < mxml.legacy.IIterable & handle
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
            b = builtin('isempty', this) | cellfun('isempty', {this.arr});
        end
        function b = any(this)
            b = any(this.arr);
        end
        function varargout = size(this, dim)
            if isempty(this)
                if nargin < 2
                    s = builtin('size', this);
                else
                    s = builtin('size', this, dim);
                end
            else
                if nargin < 2
                    s = size(this.arr);
                else
                    s = size(this.arr, dim);
                end
            end
            
            if nargout > 1
                for i = nargout:-1:1
                    if i > numel(s)
                        varargout{i} = 0;
                    else
                        varargout{i} = s(i);
                    end
                end
            else
                varargout = {s};
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

