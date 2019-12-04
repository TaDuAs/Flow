function setSize(h, siz, units)
% setSize sets the size of a handle in the desired units without changing
% it's location and changes the units of that element back to the original
% setting
    if nargin < 3; units = 'norm'; end

    pos = sui.getPos(h, units);
    pos([3,4]) = siz;
    sui.setPos(h, pos, units);
end

