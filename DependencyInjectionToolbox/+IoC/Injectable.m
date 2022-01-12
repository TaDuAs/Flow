classdef Injectable < mfc.IDescriptor
    %INJECTABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DependencyName string;
    end
    
    methods (Hidden)
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = "&DependencyName";
            defaultValues = {};
        end
    end
    
    methods
        function this = Injectable(dependencyName)
            if iscell(dependencyName) 
                this = cellfun(@IoC.Injectable, dependencyName);
            elseif isstring(dependencyName) && numel(dependencyName) > 1
                this = arrayfun(@IoC.Injectable, dependencyName);
            else
                this.DependencyName = dependencyName;
            end
        end
    end
end

