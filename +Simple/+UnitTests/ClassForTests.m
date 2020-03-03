classdef ClassForTests < handle
    %CLASSFORTESTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id='';
        vec;
        innerClass;
        innerStruct;
        str = '';
    end
    
    methods
        function this = ClassForTests(id, vec, innerClass, innerStruct)
            if nargin >= 1 && ~isempty(id)
                if ~ischar(id)
                    error('id should be char array');
                end
                this.id = id;
            end
            if nargin >= 2 && ~isempty(vec)
                this.vec = vec;
            end
            if nargin >= 3 && ~isempty(innerClass)
                this.innerClass = innerClass;
            end
            if nargin >= 4 && ~isempty(innerStruct)
                this.innerStruct = innerStruct;
            end
        end
        
        function func(this, str)
            this.str = str;
        end
        
        function x = func1(this)
            x = this.str;
        end
        
        function result = ismember(a, b)
            if isempty(a) || isempty(b)
                result = zeros(length(a));
            else
                result = ismember({a.id}, {b.id});
            end
        end
        function result = eq(a,b)
            result = strcmp({a.id}, {b.id});
        end
        function result = ne(a,b)
            result = ~(eq(a,b));
        end
    end
end

