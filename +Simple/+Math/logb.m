function value = logb(x, b, n)
% Calculates the log of x in the base b.
% If b is not specified, b is assumed to be Euler numer (e)
% Varriables:
%   x - the number to calculate log for. log_b(x)
%   b - the logarithms basis. log_b(x)
%   n - number of significant digits.

    Simple.obsoleteWarning('Simple.Math');
    import Simple.Math.*;
    if nargin < 2
        b = exp(1);
    end
    value = log(x)/log(b);
    
    % if should round to n significant digits
    if nargin > 2        
        value = rounds(value, n);
    end
end