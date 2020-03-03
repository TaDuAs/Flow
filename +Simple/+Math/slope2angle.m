function theta = slope2angle(slope)
% Converts a function slope to the angle between the tangent line and the x
% axis in radians
    theta = asin(slope/sqrt(slope^2+1));
end
