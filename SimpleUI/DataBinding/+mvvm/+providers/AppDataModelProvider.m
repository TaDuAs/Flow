classdef AppDataModelProvider < mvvm.providers.IModelProvider
    % A model provider based on Matlab's get/setappdata API
    % To enable mvvm.providers.IModelProvider event handling, the builtin
    % functions setappdata and rmappdata were overridden to enable raising
    % of an event when appdata is changed.
    % see also watchappdata for the extended app data API
    % 
    % Author: TADA
    
    properties
        Container;
        ModelAppDataEntry;
        AppDataChangeListener;
    end
    
    methods
        function this = AppDataModelProvider(container, modelAppDataEntry)
            this.Container = container;
            this.ModelAppDataEntry = modelAppDataEntry;
            
            this.AppDataChangeListener = watchappdata(@(src, args) this.raiseModelChangedEvent(args));
        end
        
        function model = getModel(this)
            model = getappdata(this.Container, this.ModelAppDataEntry);
        end
        
        function setModel(this, model)
            setappdata(this.Container, this.ModelAppDataEntry, model);
        end
        
        function delete(this)
            delete(this.AppDataChangeListener);
        end
    end
    
    methods (Access=protected)
        function raiseModelChangedEvent(this, args)
            if isequal(args.h, this.Container) && strcmp(args.name, this.ModelAppDataEntry)
                this.notify('modelChanged');
            end
        end
    end
end

