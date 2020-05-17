classdef ChildSpacingComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This is a mixin parent class for all visual components that support 
    % spacing between child components
    %
    % This class provides all implementation and storage for
    % 'Spacing'
    %
    % Author - TADA, 2020
    
    properties(Dependent)
        Spacing (1, 1) {mustBeNumeric(Spacing), mustBeFinite(Spacing), mustBeNonnegative(Spacing), mustBeReal(Spacing), mustBeNonNan(Spacing)};
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
        
        Spacing_ = 0;
    end
      
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Spacing(this, newValue)
            % Property Setting
            this.Spacing_ = newValue;
            
            % Update View
            markPropertiesDirty(this, {'Spacing'});
        end
        
        function value = get.Spacing(this)
            value = this.Spacing_;
        end
    end
end
