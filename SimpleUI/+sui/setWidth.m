function setWidth(h, width, units)
    pos = sui.getPos(h, units);
    
    pos(3) = width;
    
    sui.setPos(h, pos, units);
end

