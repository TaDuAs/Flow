classdef (ConstructOnLoad) EventArg < event.EventData
    %EVENTARGS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        arg
    end
    
    methods
        function this = EventArg(arg)
            Simple.obsoleteWarning();
            this.arg = arg;
        end
    end
end

