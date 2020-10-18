classdef PreferencesProvider < mvvm.providers.IModelProvider
    properties (Access=private)
        App mvvm.GuiApp;
    end
    
    methods
        % Gets the model from persistence layer
        function model = getModel(this)
            model = this.App.Preferences;
        end
        
        % Sets the model in persistence layer
        function setModel(this, model)
            if ~isequal(model, this.App.Preferences)
                this.App.Preferences = model;
                this.notify('modelChanged');
            end
        end
    end
    
    methods
        function this = PreferencesProvider(app)
            this.App = app;
        end
    end
end

