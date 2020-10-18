classdef DirectionallyAlignableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This is a mixin parent class for all visual components that support
    % direction alignment (Left to right/Right to left)
    %
    % This class provides all implementation and storage for
    % 'DirectionAlignment'
    %
    
    properties(Dependent)
        DirectionAlignment = 'ltr';
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
        
        DirectionAlignment_ = 'ltr';
    end
      
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.DirectionAlignment(this, newValue)
            % Error Checking
            try
                newDirAlign = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    this, ...
                    newValue, ...
                    {'ltr', 'rtl'});
            catch ex
                messageObj = message('MATLAB:ui:components:invalidTwoStringEnum', ...
                    'DirectionAlignment', 'ltr', 'rtl');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidHorizontalAlignment';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(this, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            this.DirectionAlignment_ = newDirAlign;
            
            % Update View
            markPropertiesDirty(this, {'DirectionAlignment'});
        end
        
        function value = get.DirectionAlignment(this)
            value = this.DirectionAlignment_;
        end
    end
end
