classdef (Abstract) IBinderBase < handle
    events
        modelUpdated;
    end
    
    methods (Abstract)
        start(this);
        stop(this);
        tf = isSubjectToControl(this, control);
    end
end

