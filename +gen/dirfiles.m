function [details, names, fullPaths] = dirfiles(path, varargin)
% lists the files in a folder.
% 
% listing = gen.dirfiles()
%   lists the files under the current matlab path
%  Output:
%   listing - attributes struct array for the list of files
%
% listing = gen.dirfiles(path)
%   lists the files under the specified path
%  Output:
%   listing - attributes struct array for the list of files
% 
% listing = gen.dirfiles(path, filePattern1, filePattern2, ..., filePatternN)
%   lists the files under the specified path whose name or suffix match 
%   either of the included patterns.
%  Input:
%   filePatterni - string scalar or character vector containing pattern for
%       matching file name. If the pattern contains a dot (.), then that
%       pattern is used as is, but if no dot is included, the pattern is
%       considered a file suffix, and a *. is appended at the start of the
%       pattern:
%           gen.dirfiles(path,'m') is the same as gen.dirfiles(path,'*.m')
%  Output:
%   listing - attributes struct array for the list of files
%
% [listing, names] = gen.dirfiles(___)
%   also returns a cell array of character vectors containing the list of 
%   file names
%  Output:
%   listing - attributes struct array for the list of files
%   names   - cell array of character vectors which contains the list of
%       file names
%
% [listing, names, fullPaths] = gen.dirfiles(___)
%   also returns a cell array of character vectors containing the list of 
%   file full paths
%  Output:
%   listing   - attributes struct array for the list of files
%   names     - cell array of character vectors which contains the list of
%       file names
%   fullPaths - cell array of character vectors which contains the list of
%       file full paths
%
% Author: TADA 2020
%

    if nargin < 1 || isempty(path)
        path = pwd();
    end
    filePattern = varargin;
    if nargin < 2 || isempty(filePattern)
        filePattern = {''};
    elseif isstring(filePattern) || ischar(filePattern)
        filePattern = cellstr(filePattern);
    end
    
    % append *. to all postfixes
    postfixMask = ~contains(filePattern, '.') & ~cellfun('isempty', filePattern);
    filePattern(postfixMask) = strcat('*.', filePattern(postfixMask));
    
    % get file listings
    details = dir(fullfile(path, filePattern{1}));
    for i = 2:numel(filePattern)
        details = vertcat(details, dir(fullfile(path, filePattern{i})));
    end
    
    % remove folders
    details = details(~[details.isdir]);
    
    % remove duplicates
    [names, idxUniques] = unique({details.name});
    details = details(idxUniques);
    
    % prep list of full paths
    if nargout >= 3
        fullPaths = fullfile(path, names);
    end
end

