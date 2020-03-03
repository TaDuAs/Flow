classdef PipelineTask < handle & matlab.mixin.Heterogeneous
    % This abstract class exposes the necessary methods for a pipeline task
    
    methods
        function returnedData = process(this, data)
            error('must implement this in deriving class');
        end
            
        function plotData(this, fig, data)
        end
        
        function init(this, settings)
        end
    end
    
end

