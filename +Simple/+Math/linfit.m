function [a,b,R2] = linfit(x,y)
% So apparently polyfit works strange when x has changing intervals ?!
% Calculates the y=a*x+b linear regression
% Returns
%   a - slope
%   b - y intercept
%   R2 - R square of regression

    n = length(x);
    sx = sum(x);
    sy = sum(y);
    sxy = sum(x.*y);
    sxx = sum(x.^2);
    syy = sum(y.^2);
    sx2 = sum(x)^2;

    a = (n*sxy-sx*sy)/(n*sxx-sx2);
    b = (sy*sxx-sx*sxy)/(n*sxx-sx2);
    if (nargout > 2)
        R2 = (n*sxy-sx*sy)^2/((n*sxx-sx2)*(n*syy-sy^2));
    end
end