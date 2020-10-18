classdef (Abstract) IRedrawable < handle
    methods(Abstract, Access=protected)
        redraw(this);
    end % abstract template methods
end

