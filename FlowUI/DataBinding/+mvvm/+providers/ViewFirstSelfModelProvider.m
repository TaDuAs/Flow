classdef ViewFirstSelfModelProvider < mvvm.providers.IModelProvider
    %VIEWFIRSTMODELPROVIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ViewModelPropertyName;
    end
    
    methods
        function this = ViewFirstModelProvider(prop)
            this.ViewModelPropertyName = prop;
            addlistener(this, prop, 'PostSet', @ClassName.handlePropertyEvents);
        end
        
        function model = getModel(this)
        % Gets the model from persistence layer
            model = this.(this.ViewModelPropertyName);
        end
        
        function setModel(this, model)
        % Sets the model in persistence layer
            this.(this.ViewModelPropertyName) = model;
        end
        
        function raiseModelChanged(this)
            
        end
    end
end

