function [err, ci] = econfi(x, a, stdev, n)
import Simple.Math.*;
% confi calculates the confidence interval for a distribution of values
% Varriables:
%   x - data array\
%   a - level of significance
%   stdev - precalculated standard deviation
%   n - number of values in 
% Returns:
%   err - the error value for +/- stuff
%   ci  - the confidence interval

    if nargin < 3
        [err, ci] = confi(x, a);
    else
        if nargin < 4
            n = length(x);
        end
        if length(x) > 1
            x = mean(x);
        end

        SEM = stdev/sqrt(n);        % Standard Error
        ts = tinv([a, 1-a], n-1);   % T-Score
        ci = x + ts.*SEM;           % Confidence Intervals
        err = max(ts)*SEM;
    end
end