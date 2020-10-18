classdef VRowAlignableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This is a mixin parent class for all visual components that render 
    % support multiple rows and support row vertical alignment
    %
    % This class provides all implementation and storage for
    % 'VRowAlignment'
    %
    
    properties(Dependent)
        VRowAlignment = 'center';
    end
    
    properties(Access = 'private')
        % Internal properties
        %
        % These exist to provide: 
        % - fine grained control for each property
        %
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        VRowAlignment_ = 'center';
    end
      
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.VRowAlignment(this, newValue)
            % Error Checking
            try
                newDirAlign = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    this, ...
                    newValue, ...
                    {'top', 'center', 'bottom'});
            catch ex
                messageObj = message('MATLAB:ui:components:invalidThreeStringEnum', ...
                    'VRowAlignment', 'top', 'center', 'bottom');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidHorizontalAlignment';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(this, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            this.VRowAlignment_ = newDirAlign;
            
            % Update View
            markPropertiesDirty(this, {'VRowAlignment'});
        end
        
        function value = get.VRowAlignment(this)
            value = this.VRowAlignment_;
        end
    end
end
