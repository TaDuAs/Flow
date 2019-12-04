classdef FunctionHandleDataAdapter < mvvm.IDataAdapter
    properties
        model2guiAdapterMethod;
        gui2modelAdapterMethod;
    end
    
    methods
        function this = FunctionHandleDataAdapter(model2guiAdapterMethod, gui2modelAdapterMethod)
            if nargin >= 1 
                this.model2guiAdapterMethod = model2guiAdapterMethod;
            end
            if nargin >= 2
                this.gui2modelAdapterMethod = gui2modelAdapterMethod;
            end
        end
        
        function out = model2gui(this, value)
            if ~isempty(this.model2guiAdapterMethod)
                out = this.model2guiAdapterMethod(value);
            else
                out = value;
            end
        end
        
        function out = gui2model(this, value)
            if ~isempty(this.gui2modelAdapterMethod)
                out = this.gui2modelAdapterMethod(value);
            else
                out = value;
            end
        end
    end
end

