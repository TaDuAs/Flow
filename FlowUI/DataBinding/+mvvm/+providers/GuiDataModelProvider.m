classdef GuiDataModelProvider < mvvm.providers.AppDataModelProvider
    % Sugar coated AppDataModelProvider for those of us that prefer using guidata
    
    methods
        function this = GuiDataModelProvider(fig)
            this@mvvm.providers.AppDataModelProvider(fig, 'UsedByGUIData_m');
        end
        
        function model = getModel(this)
            model = guidata(this.Container);
        end
    end
end

