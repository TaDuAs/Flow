function value = str2boolean(str)
    strVal = strsplit(str, ' ');
    value = true(1, numel(strVal));
    value(strcmp('false', strVal)) = false;
    numericStrings = regexp(strVal, '^\d+$', 'match');
    numericMask = ~cellfun('isempty', numericStrings);
    value(numericMask) = logical(cellfun(@str2double, numericStrings(numericMask)));
end