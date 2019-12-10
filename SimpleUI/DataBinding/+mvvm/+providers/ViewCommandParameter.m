classdef ViewCommandParameter < mvvm.providers.IModelProvider
    % ViewCommandParameter is a dynamic parameter for command binding using
    % mvvm.Command
    % It provides dynamic access to a property of the view control to send
    % to the command, such as listbox value for Callback command.
    % this is good if the index cannot be used for two way databinding for
    % some reason.
    %
    % Author: TADA 2019
    
    properties
        control;
        propName;
    end
    
    methods
        function this = ViewCommandParameter(control, propName)
            this.control = control;
            this.propName = propName;
        end
        
        % Gets the model from persistence layer
        function model = getModel(this)
            model = this.control.(this.propName);
        end
        
        % Sets the model in persistence layer
        function setModel(this, model)
            % should not be used ever
        end
    end
end

