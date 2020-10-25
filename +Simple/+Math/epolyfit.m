function [p, s, mu] = epolyfit(x, y, n)
% epolyfit - Extended Polynomial Fit.
% Parametrs:
%   x - X axis values
%   y - Y axis values
%   n - Polynom order
% Returns:
%   p  - The polynom coefficients in declining order, for example, a 2nd
%        order polynomial fit coefficients will a vector:[2nd, 1st, 0th]
%   s  - Fitting error estimate.
%        For n = 0  - s = []
%        For 1<=n<=2  - s = R^2
%        For n > 2 - s = struct(R=[n+1xn+1], df=[1x1], normr=[1x1])
%   mu - mean and standard deviation of the residues
    
    Simple.obsoleteWarning('Simple.Math');
    import Simple.Math.*;
    % so apparently polyfit needs the x array to have constant intervals ?!
    if (n == 2)
        [p, R2] = quadraticReggression(x, y);
        s = R2;
        deviations = y - ((p(1)*(x.^2))+(p(2)*x)+p(3));
        mu = [mean(deviations), std(deviations)];
    elseif (n == 1)
        [a,b,R2] = linfit(x, y);
        p = [a, b];
        s = R2;
        deviations = y - ((x*a)+b);
        mu = [mean(deviations), std(deviations)];
    % Not to mention that the std and avg are calculated for x and
    % not y. They actualy write mu =[mean(x) std(x)] WTF?!
    % Who gives a damn about that BS??
    elseif (n == 0)
        p = mean(y);
        s = [];
        mu = [p std(y)];
    else
        [p, s, mu] = polyfit(x, y, n);
        reggressionValues = polyval(p, x, s, mu);
        deviations = y - reggressionValues;
        mu = [mean(deviations), std(deviations)];
    end
end


function [p, R2] = quadraticReggression(x, y)
% calculate the 2nd order polynomial fit for x and y
% y = ax^2+bx+c
% Returns:
%   p = [a,b,c]
%   R2 - R square of regression

    n = length(x);
    xAvg = sum(x)/n;
    yAvg = sum(y)/n;
    x2Avg = sum(x.^2)/n;
    
    Sxx = x2Avg-(xAvg^2);
    Sxy = sum(x.*y)/n-(xAvg*yAvg);
    Sxx2 = sum(x.^3)/n - (xAvg*x2Avg);
    Sx2x2 = sum(x.^4)/n - (x2Avg^2);
    Sx2y = sum((x.^2).*y)/n - (x2Avg*yAvg);

    a = (Sx2y*Sxx-Sxy*Sxx2)/(Sxx*Sx2x2-Sxx2^2);
    b = (Sxy*Sx2x2-Sx2y*Sxx2)/(Sxx*Sx2x2-Sxx2^2);
    c = yAvg - b*xAvg - a*x2Avg;
    
    p = [a b c];
    R2 = sqrt(1-sum((y-(a*x.^2+b*x+c)).^2)/sum((y-yAvg).^2));
end