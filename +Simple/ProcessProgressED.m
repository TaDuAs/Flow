classdef (ConstructOnLoad) ProcessProgressED < event.EventData
    %PROCESSPROGRESSED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        progressReported;
        totalProgress;
        processingLeft;
    end
    
    methods
        function this = ProcessProgressED(progressReported, totalProgress, processingLeft)
            this.progressReported = progressReported;
            this.totalProgress = totalProgress;
            this.processingLeft = processingLeft;
        end
    end
    
end

