classdef (Abstract) IBindingManager < handle
    events
        % Raised when the modelUpdated event is fired in one of the binders 
        % associated with this mvvm.IBindingManager
        %
        % This is useful in case a specific command is required upon any
        % model update, such as redraw of a data-panel when the
        % configuration panel is updated
        modelUpdated;
    end
    
    methods (Abstract)
        % getDefaultProvider returns the default provider
        modelProvider = getDefaultProvider(this);
        
        % sets a new default provider to replace the existing default
        % behaviour
        setDefaultModelProvider(this, modelProvider);
        
        % sets the model provider associated with the specified container
        % If one is already associated with it, replace it with the new one
        setModelProvider(this, container, modelProvider);
        
        % removes the model provider at the specified index
        removeModelProvider(this, container);
        
        % gets the model provider associated with the specified container
        % if no provider is found, returns the default model provider
        modelProvider = getModelProvider(this, container);
        
        % saves a reference of a data binder.
        % mvvm.Binder instances are referenced by mvvm.BindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.BindingManager during construction and remove themselves
        % upon destruction
        saveBinder(this, binder);
        
        % removes all reference of a data binder from the
        % mvvm.BindingManager.
        % mvvm.Binder instances are referenced by mvvm.BindingManager to
        % keep them alive without having to keep a reference in the base
        % workspace or to couple to GUI handles.
        % mvvm.Binder automatically send tehmselves to the 
        % mvvm.BindingManager during construction and remove themselves
        % upon destruction
        clearBinder(this, binder);

        % Activates all binders subject to the container control
        activateBindersDomain(this, containerControl);
        
        % Deactivates all binders subject to the container control
        deactivateBindersDomain(this, containerControl);
    end
end

