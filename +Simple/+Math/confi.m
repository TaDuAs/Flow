function [err, ci] = confi(x, a)
% confi calculates the confidence interval for a distribution of values
% Varriables:
%   x - data array
%   a - level of significance
% Returns:
%   err - the error value for +/- stuff
%   ci  - the confidence interval

    Simple.obsoleteWarning('Simple.Math');
n = length(x);
SEM = std(x)/sqrt(n);       % Standard Error
ts = tinv([a, 1-a], n-1);   % T-Score
ci = mean(x) + ts*SEM;      % Confidence Intervals
err = max(ts)*SEM;
end

