function path = processOutputIOPath(path, timestamp)
            Simple.obsoleteWarning('Simple.DataAccess');
    if nargin < 2
        timestamp = now;
    end
    path = strrep(path, '{timestamp}', datestr(timestamp, 'yyyy-mm-dd_HH.MM.SS.FFF'));
end

