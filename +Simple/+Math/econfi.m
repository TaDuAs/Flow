function [err, ci] = econfi(x, a, stdev, n)
% confi calculates the confidence interval for a distribution of values
% Varriables:
%   x - data array
%   a - level of significance
%   stdev - precalculated standard deviation
%   n - number of values in 
% Returns:
%   err - the error value for +/- stuff
%   ci  - the confidence interval

    if nargin < 3
        [err, ci] = ForSDAT.util.confi(x, a);
    else
        if nargin < 4
            n = length(x);
        end
        if length(x) > 1
            x = mean(x);
        end

        SEM = stdev/sqrt(n);        % Standard Error
        a_half = a/2;
        ts = tinv([a_half, 1-a_half], n-1);   % T-Score
        ci = x + ts.*SEM;           % Confidence Intervals
        err = max(ts)*SEM;
    end
end