function str = charmat2str(value)
    [n, m] = size(value);
    if n > 1
        str = char(zeros([1, n*m+n-1]));
        for i = 1:n
            idx = (i-1)*(m+1)+1;
            str(idx:idx+m-1) = value(i, :);
            if i < n
                str(idx+m) = ';';
            end
        end
    else
        str = value;
    end
end