classdef (Abstract) IDataAdapter
    methods
        out = model2gui(this, value);
        out = gui2model(this, value);
    end
end

