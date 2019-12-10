function value = str2num(str)
    value = cellfun(@str2double, strsplit(strtrim(str)));
    value = value(~isnan(value));
end

