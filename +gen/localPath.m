function path = localPath(varargin)
% localPath returns the full file system path of the calling file
% can append more parts to the path by sending strings or character vectors
% as input

    dbs = dbstack('-completenames');
    path = fileparts(dbs(2).file);
    
    if nargin >= 1
        path = fullfile(path, varargin{:});
    end
end