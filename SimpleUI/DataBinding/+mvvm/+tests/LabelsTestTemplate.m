classdef LabelsTestTemplate < mvvm.ITemplate
    methods
        function h = build(template, scope, container)
            h.lbl = uicontrol('style', 'text', 'tag', [strjoin(scope.ModelPath, '_') scope.Key], 'Parent', container);
            
            % not really necessary to reference the binder in the handles 
            % struct, as its references in the binding manager, and it 
            % destroys itself when the bound control is destroyed.
            h.binder = mvvm.Binder('', h.lbl, 'String', 'ModelProvider', scope);
        end
        
        function teardown(template, scope, container, h)
            % this is commented out as binders listen to
            % control destruction event and clean themselves up
            % automatically.
            % delete(h.binder);
            delete(h.lbl);
        end
    end
end