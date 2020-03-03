function oom = doom(val, roundFirst)
% doom - Decimal Order of Magnitude
% Determines the order of magnitude of a specified number.
% Varriables:
%   val: number. The number to calculate OOM for.
%   roundFirst: boolean. Determines whether to round the number to 
%               a single significant digit prior to getting the Log
    if (val == 0)
        oom = 0;
        return;
    elseif val < 0
        val = val*-1;
    end

    oom = floor(log10(val));

    % if the oom of the rounded value is wanted,
    % determine if the value is above half way to next oom
    % not using regular round function because only 5 and higher
    % values are expected to be rounded up to 10
    % however, log(3.1623) = 0.5 and will be rounded up by round()
    if nargin > 1 && roundFirst
        roundedValue = arrayfun(@round, val,-oom);
        oom = floor(log10(roundedValue));
    end
end