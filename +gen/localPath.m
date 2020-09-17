function path = localPath(varargin)
% localPath returns the full file system path of the calling file
% can append more parts to the path by sending strings or character vectors
% as input
%
% path = gen.localPath()
%   returns the path of the file containing the calling function
%   when called from the command line, the current working directory is
%   returned
%
% path = gen.localPath(varargin)
%   also appends the specified list of subfolder names under the local path
% 
% Author: TADA, 2020

    dbs = dbstack('-completenames');
    
    if numel(dbs) < 2
        % this means it was most likely called from the command line
        % in that case, the local path should be current Matlab working
        % directory
        path = pwd();
    else
        path = fileparts(dbs(2).file);
    end
    
    % also append added folders
    if nargin >= 1
        path = fullfile(path, varargin{:});
    end
end