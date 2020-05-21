function value = rounds(x, n)
% Rounds number to a number of significant digits
    Simple.obsoleteWarning('Simple.Math');
    import Simple.Math.*;
    if n < 1 || mod(n,1) > 0
        error('n must be a whole positive number');
    end
    
    oom = doom(x);
    
    value = round(x, n-oom-1);
end