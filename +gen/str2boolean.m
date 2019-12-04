function value = str2boolean(str)
    strVal = regexp(str, '[\s,]+', 'split');
    numValues = length(strVal);
    value = true(1, numValues);
    for i = 1:numValues
        if strcmp('true', strVal(i))
            value(i) = true;
        elseif strcmp('false', strVal(i))
            value(i) = false;
        else 
            value(i) = logical(str2double(strVal(i)));
        end
    end
end

