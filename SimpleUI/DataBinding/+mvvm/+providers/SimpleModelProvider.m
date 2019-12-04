classdef SimpleModelProvider < mvvm.providers.IModelProvider
    % The simplest possible model provider, offers no persistence of any
    % kind, except for the persistence provided by mvvm.BindingManager 
    % singleton or by the user.
    % Use setModel to set the model and raise the model changed event
    
    properties (GetAccess=protected,SetAccess=protected)
        model;
    end
    
    methods
        function this = SimpleModelProvider(model)
            if nargin >= 1 && ~isempty(model)
                this.setModel(model)
            end
        end
        
        function model = getModel(this)
            model = this.model;
        end
        
        function setModel(this, model)
            if ~isequal(model, this.model)
                this.model = model;
                this.notify('modelChanged');
            end
        end
    end
end

