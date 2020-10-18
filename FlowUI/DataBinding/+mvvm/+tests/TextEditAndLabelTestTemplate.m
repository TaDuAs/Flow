classdef TextEditAndLabelTestTemplate < mvvm.ITemplate
    properties
        UpdateDelay;
    end
    methods
        function this = TextEditAndLabelTestTemplate(updateDelay)
            if nargin < 1; updateDelay = 0.2; end
            this.UpdateDelay = updateDelay;
        end
        
        function h = build(template, scope, container)
            h.txt = uicontrol('style', 'edit', 'tag', [strjoin(scope.ModelPath, '_') num2str(scope.Key)], 'Parent', container);
            h.lbl = uicontrol('style', 'text', 'tag', [strjoin(scope.ModelPath, '_') num2str(scope.Key)], 'Parent', container);
            
            % not really necessary to reference the binder in the handles 
            % struct, as its references in the binding manager, and it 
            % destroys itself when the bound control is destroyed.
            h.binder = mvvm.Binder('', h.txt, 'String',...
                'ModelProvider', scope,...
                'Event', 'KeyReleaseFcn',...
                'UpdateDelay', template.UpdateDelay);
            h.binder = mvvm.Binder('', h.lbl, 'String', 'ModelProvider', scope);
        end
        
        function teardown(template, scope, container, h)
            % this is commented out as binders listen to
            % control destruction event and clean themselves up
            % automatically.
            % delete(h.binder);
            delete(h.txt);
            delete(h.lbl);
        end
    end
end