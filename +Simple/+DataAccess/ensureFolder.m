function [status, msg, id] = ensureFolder(path)
    if ~exist(path, 'dir')
        [status, msg, id] = Simple.DataAccess.createFolder(path);
    else
        status = true;
        msg = '';
        id = '';
    end
end

