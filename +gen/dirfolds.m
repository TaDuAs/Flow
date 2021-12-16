function [details, names, fullPaths] = dirfolds(path, varargin)
% lists the files in a folder.
% 
% listing = gen.dirfolds()
%   lists the subfolders under the current matlab path
%  Output:
%   listing - attributes struct array for the list of subfolders
%
% listing = gen.dirfolds(path)
%   lists the subfolders under the specified path
%  Output:
%   listing - attributes struct array for the list of subfolders
% 
% [listing, names] = gen.dirfolds(___)
%   also returns a cell array of character vectors containing the list of 
%   subfolder names
% 
% [listing, names, fullPaths] = gen.dirfolds(___)
%   also returns a cell array of character vectors containing the list of 
%   subfolder full path
%
% Author: TADA 2020
%

    if nargin < 1 || isempty(path)
        path = pwd();
    end
    searchStrings = varargin;
    if nargin < 2 || isempty(searchStrings)
        searchStrings = {''};
    elseif isstring(searchStrings) || ischar(searchStrings)
        searchStrings = cellstr(searchStrings);
    end
    
    % apply search strings to the path
    details = dir(fullfile(path, searchStrings{1}));
    for i = 2:numel(searchStrings)
        details = vertcat(details, dir(fullfile(path, searchStrings{i})));
    end
    
    % only keep folders
    details = details([details.isdir]);
    
    % remove current directory and parent directory
    details(ismember({details.name}, {'.', '..'})) = [];
    
    % prep list of names
    if nargout >= 2
        names = {details.name};
    end
    
    % prep list of full paths
    if nargout >= 3
        fullPaths = fullfile(path, names);
    end
end

