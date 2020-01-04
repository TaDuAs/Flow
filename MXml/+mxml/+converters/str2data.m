function value = str2data(str, type)
    if strlength(str) == 0
        value = feval([type '.empty']);
        return;
    end
    cts = textscan(str, '%f', 'EndOfLine', ';', 'Delimiter', {' ', '\t', ','}, 'MultipleDelimsAsOne', true);
    temp = cts{1};

    % determine matrix size from first row
    firstRowDelim = regexp(str, ';', 'once');
    if isempty(firstRowDelim)
        value = temp';
    else
        % get first row
        firstRow = string(extractBetween(str, 1, firstRowDelim-1));

        % get number of items in first row
        itemsInFirstRow = regexp(firstRow, '\s+', 'split');
        n = sum(itemsInFirstRow ~= '');
        m = numel(temp)/n;

        % change temporary vector size to fit the correct matrix
        % size
        value = reshape(temp, n, m)';
    end

    % cast from double to whatever
    if nargin >= 2
        value = cast(value, type);
    end
end