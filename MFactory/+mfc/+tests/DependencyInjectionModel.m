classdef DependencyInjectionModel < mfc.IDescriptor
    %DEPENDENCYINJECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        input;
    end
    
    % IDescriptor provides information on proper initialization and 
    % which properties to set for mfc.MFactory
    methods % factory meta data
        % provides initialization description for mfc.MFactory
        % ctorParams is a cell array which contains the parameters passed to
        % the ctor and which properties are to be set during construction
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'@blah', '%Blah', '@text', "text"};
            defaultValues = {};
        end
    end
    
    methods
        function this = DependencyInjectionModel(varargin)
            this.input = varargin;
        end
    end
end

