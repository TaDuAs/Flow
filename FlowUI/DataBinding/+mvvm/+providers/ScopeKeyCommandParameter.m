classdef ScopeKeyCommandParameter < mvvm.providers.IModelProvider
    % ScopeKeyCommandParameter is a dynamic parameter for command binding 
    % using mvvm.Command
    % It provides dynamic access to the scope key rather than the usual
    % scoped value to send to the command
    %
    % Author: TADA 2019
    
    properties
        scope;
    end
    
    methods
        function this = ScopeKeyCommandParameter(scope)
            this.scope = scope;
        end
        
        % Gets the model from persistence layer
        function model = getModel(this)
            model = this.scope.Key;
        end
        
        % Sets the model in persistence layer
        function setModel(this, model)
            % should not be used ever
        end
    end
end