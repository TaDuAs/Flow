classdef NoopDataAdapter < mvvm.IDataAdapter
    methods
        function out = model2gui(~, value)
            out = value;
        end
        
        function out = gui2model(~, value)
            out = value;
        end
    end
end

