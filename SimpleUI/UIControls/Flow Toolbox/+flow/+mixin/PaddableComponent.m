classdef PaddableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This is a mixin parent class for all visual components that support 
    % Padding between the edges and contents
    %
    % This class provides all implementation and storage for
    % 'Padding'
    %
    % Author - TADA, 2020
    
    properties(Dependent)
        Padding (1, 1) {mustBeNumeric(Padding), mustBeFinite(Padding), mustBeNonnegative(Padding), mustBeReal(Padding), mustBeNonNan(Padding)};
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
        
        Padding_ = 0;
    end
      
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Padding(this, newValue)
            % Property Setting
            this.Padding_ = newValue;
            
            % Update View
            markPropertiesDirty(this, {'Padding'});
        end
        
        function value = get.Padding(this)
            value = this.Padding_;
        end
    end
end
