classdef DynamicCommandParameter < mvvm.providers.IModelProvider
    % DynamicCommandParameter is a dynamic parameter for command binding
    % using mvvm.Command
    % It provides a dynamic value using a function handle. This is good for
    % instance to call a command with a parameter retrieved from a matlab
    % function that is strictly view related such as ginput.
    %
    % Author: TADA 2019
    
    properties
        action;
    end
    
    methods
        function this = DynamicCommandParameter(action)
            this.action = action;
        end
        
        function model = getModel(this)
            model = this.action();
        end
        
        function setModel(this, model)
            % should not be called ever
            error('Theres no reason in the world for a Command parameter''s set method to be used');
        end
    end
end

