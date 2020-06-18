function siz = getSize(h, units, type)
%GETSIZE gets the size vector of a handle in the desired units and
%changes the units of that element back to the original setting
    if nargin < 2; units = 'norm'; end
    if nargin < 3; type = ''; end

    pos = sui.getPos(h, units, type);
    siz = pos([3,4]);
end

