function err = calcerr(x, dx, func)
    Simple.obsoleteWarning('Simple.Math');
    if strcmp(func, 'ln')
        err = dx./x;
    else
        err = dx;
    end
end

