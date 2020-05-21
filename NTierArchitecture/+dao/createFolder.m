function [status, msg, id] = createFolder(path)
    lastSeparator = find(path == filesep(), 1, 'last');
    pathstr = path(1:lastSeparator-1);
    newDir = path(lastSeparator+1:end);
    if isempty(pathstr)
        [status, msg, id] = mkdir(path);
    else
        [status, msg, id] = mkdir(pathstr, newDir);
    end
end