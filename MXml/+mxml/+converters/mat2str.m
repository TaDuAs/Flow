function str = mat2str(value)
    if isempty(value)
        str = '';
        return;
    end
    if islogical(value)
        value = double(value);
    end
    str = mat2str(value);
    if length(value) > 1
        str = str(2:length(str)-1);
    end
end