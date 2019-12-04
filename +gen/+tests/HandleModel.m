classdef HandleModel < handle & mfc.IDescriptor
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
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'id', 'child1', 'child2', 'list'};
            defaultValues = {'id', [], 'child1', [], 'child2', [], 'list', []};
        end
        
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
    end
end

