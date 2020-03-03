function err = calcerr(x, dx, func)
    if strcmp(func, 'ln')
        err = dx./x;
    else
        err = dx;
    end
end

