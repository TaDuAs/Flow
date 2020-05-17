function setHeight(h, height, units)
    pos = sui.getPos(h, units);
    
    pos(4) = height;
    
    sui.setPos(h, pos, units);
end

