classdef HandleModel < handle
    %MODELROOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable)
        child1;
        child2;
        id;
        list;
        didSomething;
    end
    
    methods
        
        function this = HandleModel(id, child1, child2, list)
            if nargin >= 1
                this.id = id;
                if nargin >= 2
                    this.child1 = child1;
                    if nargin >= 3
                        this.child2 = child2;
                        if nargin >= 4
                            this.list = list;
                        end
                    end
                end
            end
        end
        
        function doSomething(this, a, b, c)
            this.didSomething = struct();
            this.didSomething.n = nargin;
            if nargin >= 2
                this.didSomething.a = a;
            end
            if nargin >= 3
                this.didSomething.b = b;
            end
            if nargin >= 4
                this.didSomething.c = c;
            end
        end
        
        function x = random(this, n)
            x = rand(1,n);
        end
    end
end

