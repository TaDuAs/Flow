function theta = lineAngle(x, y, indices)
% Determines the angle between a linear function and the x axis in radians
    import Simple.Math.*;
    if nargin < 3
        indices = [1, 2];
    end

    if (length(indices) > 2)
        [a,~] = linfit(x(indices),y(indices));
        dx = 1;
        dy = a;
    else
        ind_s = indices(1);
        ind_f = indices(2);
        dx = x(ind_f)-x(ind_s);
        dy = y(ind_f)-y(ind_s);
    end

    theta = slope2angle(dy/dx);
end
