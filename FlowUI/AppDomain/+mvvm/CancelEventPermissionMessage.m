classdef CancelEventPermissionMessage < mvvm.PermissionMessage
    
    properties
        EventData (1,1) gen.CancelEventData;
    end
    
    methods
        function this = CancelEventPermissionMessage(id, eventData, varargin)
            this@mvvm.PermissionMessage(id, varargin{:});
            this.EventData = eventData;
        end
        
        function forbid(this)
            forbid@mvvm.PermissionMessage(this);
            
            this.updateEventData();
        end
        
        function allow(this)
            allow@mvvm.PermissionMessage(this);
            
            this.updateEventData();
        end
    end
    
    methods (Access=private)
        function updateEventData(this)
            this.EventData.Cancel = ~this.PermissionGranted;
        end
    end
end

