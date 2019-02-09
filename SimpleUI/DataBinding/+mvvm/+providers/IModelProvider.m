classdef (Abstract) IModelProvider < handle
    % Implement this interface class to supply model access for data binder
    
    methods (Abstract)
        % Gets the model from persistence layer
        model = getModel(this);
        
        % Sets the model in persistence layer
        setModel(this, model);
    end
    
    events
        % fires when the entire model is set from outside
        modelChanged;
    end
end

