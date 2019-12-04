function tf = isSingleString(str)
    if iscell(str) && numel(str) == 1
        str = str{1};
    end
    tf = isStringScalar(str) || (ischar(str) && (isrow(str) || isscalar(str) || isempty(str)));
end

