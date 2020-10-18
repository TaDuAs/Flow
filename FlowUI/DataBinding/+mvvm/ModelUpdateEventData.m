classdef ModelUpdateEventData < event.EventData
    %MODELUPDATEEVENTDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Binder mvvm.IBinderBase = mvvm.Binder.empty();
    end
    
    methods
        function this = ModelUpdateEventData(binder)
            this.Binder = binder;
        end
    end
end

