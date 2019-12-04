classdef INotifyRedrawn < handle
    %INOTIFYREDRAWN Summary of this class goes here
    %   Detailed explanation goes here
    
    events
        % this event will be raised by implementing classes whenever a
        % redraw cycle ends
        redrawn;
        
        % this event will be raised by implementing classes when the size
        % of the control changes as a result of a redraw cycle
        resized;
    end
end

