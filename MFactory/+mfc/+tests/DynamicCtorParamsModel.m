classdef DynamicCtorParamsModel < mfc.tests.HandleModel
    %DYNAMICCTORPARAMSMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'id', '@child1', 'child1', '@child2', 'child2', '@list', 'list'};
            defaultValues = {'id', ''};
        end
        
        function this = DynamicCtorParamsModel(id, varargin)
            if nargin < 1; id = []; end
            p = inputParser();
            p.addOptional('child1', []);
            p.addOptional('child2', []);
            p.addOptional('list', []);
            p.parse(varargin{:});
            
            this@mfc.tests.HandleModel(id, p.Results.child1, p.Results.child2, p.Results.list);
        end
    end
end

