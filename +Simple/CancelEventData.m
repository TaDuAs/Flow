classdef CancelEventData < event.EventData
    %CANCELEVENTDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Cancel;
    end
    
    methods
        function this = CancelEventData()
            this.Cancel = false;
        end
    end
end

