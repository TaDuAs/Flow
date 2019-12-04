classdef AppDataListener < handle
    %APPDATALISTENER Summary of this class goes here
    %   Detailed explanation goes here
    
    events
        dirty;
    end
    
    methods (Access=private)
        function this = AppDataListener()
        end
    end
    
    methods (Static)
        function listener = instance()
            persistent instance;
            if isempty(instance)
                instance = AppDataListener();
            end
            listener = instance;
        end
    end
    
    methods
        function raiseDataChanged(this, h, name)
            notify(this, 'dirty', AppDataChangedEventData(h, name));
        end
    end
end

