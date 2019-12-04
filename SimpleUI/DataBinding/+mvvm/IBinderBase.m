classdef (Abstract) IBinderBase < handle
    methods (Abstract)
        start(this);
        stop(this);
        tf = isSubjectToControl(this, control);
    end
end

