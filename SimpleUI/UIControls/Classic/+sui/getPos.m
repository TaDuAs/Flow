function pos = getPos(h, units)
%GETPOS gets the position vector of a handle in the desired units and
%changes the units of that element back to the original setting
    if nargin < 2; units = 'norm'; end
    
    % detect original units of the handle
    originalUnits = get(h, 'Units');
    changeBack = false;
    
    % change to wanted units
    if ~strcmp(units, originalUnits)
        changeBack = true;
        set(h, 'Units', units);
    end

    % get position
    pos = get(h, 'Position');
    
    % chnage units back to original value
    if changeBack
        set(h, 'Units', originalUnits);
    end
end

