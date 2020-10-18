classdef AppDataChangedEventData < event.EventData
    properties
        h;
        name;
    end
    
    methods
        function this = AppDataChangedEventData(h,name)
            this.h = h;
            this.name = name;
        end
    end
end

