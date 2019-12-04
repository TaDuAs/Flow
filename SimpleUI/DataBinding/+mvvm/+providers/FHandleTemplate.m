classdef FHandleTemplate < mvvm.ITemplate
    % A simple template which uses a given function handle to build the
    % template GUI components and destroys all handles in the handles
    % struct upon teardown.
    % ** Make sure to assign all handles in the handles struct returned 
    % ** from the builder function handle.
    %
    % Author: TADA
    
    properties
        builderFunctionHandle;
    end
    
    methods
        function this = FHandleTemplate(builderFunctionHandle)
            this.builderFunctionHandle = builderFunctionHandle;
        end
        
        function h = build(this, scope, container)
            foo = this.builderFunctionHandle;
            h = foo(scope, container);
        end
        
        function teardown(~, ~, ~, h)
        % Tears down all handles in h.
            fieldNames = fieldnames(h);
            for i = 1:length(fieldNames)
                currField = fieldNames{i};
                item = h.(currField);
                if isa(item, 'handle') && isvalid(item)
                    delete(item);
                end
            end
        end
    end
end

