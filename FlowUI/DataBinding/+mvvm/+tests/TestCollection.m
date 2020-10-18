classdef TestCollection < lists.IObservable
    %TESTCOLLECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        list;
    end
    
    methods
        function this = TestCollection(list)
            if nargin >= 1
                this.list = list;
            end
        end
        function n = length(this)
            n = length(this.list);
        end
        function n = numel(this)
            n = numel(this.list);
        end
        function b = isempty(this)
            b = isempty(this.list);
        end
        function b = any(this)
            b = any(this.list);
        end
        function s = size(this, dim)
            if nargin < 2
                s = size(this.list);
            else
                s = size(this.list, dim);
            end
        end
        function value = getv(this, i)
            if iscell(this.list)
                value = this.list{i};
            else
                value = this.list(i);
            end
        end
        function setv(this, value, i)
            if iscell(this.list)
                this.list{i} = value;
            else
                this.list(i) = value;
            end
        end
        function removeAt(this, i)
            this.list(i) = [];
        end
        function setVector(this, vector)
            this.list = vector;
        end
        function b = containsIndex(this,i)
            b = i <= numel(this.list);
        end
        function keySet = keys(this)
            keySet = 1:numel(this.list);
        end
        function add(this, value)
            this.setv(value, numel(this.list)+1);
        end
    end
end

