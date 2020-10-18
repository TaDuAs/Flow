function [filename, pathname, filterindex] = getfile(varargin)
% sui.getfile extends the functionality of uigetfile to also accept the
% filterindex argument returned from uigetfile, and sort the filter list
% accordingly to automatically select the item specified filter index.
%
% [filename, pathname, filterindex] = sui.getfile()
%   identical to uigetfile functionality
%
% [filename, pathname, filterindex] = sui.getfile(filter)
%   identical to uigetfile functionality
%
% [filename, pathname, filterindex] = sui.getfile(filter, title)
%   identical to uigetfile functionality
%
% [filename, pathname, filterindex] = sui.getfile(filter, title, defname)
%   identical to uigetfile functionality
%
% [filename, pathname, filterindex] = sui.getfile(___, [name, value])
%   also takes in optional parameters as name-value pairs
%       'MultiSelect' - identical to uigetfile
%       'FilterIndex' - the filter index returned by uigetfile. 
%           When specified, reorders the filters so that the previously 
%           selected filter will be selected by default. If not specified, 
%           the value is 1. The reordering of filter specs does not affect 
%           the returned filter index, that is, the index of the selected
%           filter is that of its location in the original cell array 
%           specified by the user. must be a positive finite integer scalar
%

    [vars, localParams] = sui.fileDialogue.parseExtenderArgs(varargin);
    
    % reorder filter specs so that the previously selected filter is
    % selected again
    vars = sui.fileDialogue.applyFilterIndex(vars, localParams);
    
    [filename, pathname, filterindex] = uigetfile(vars{:});
    
    if filename == 0
        return;
    end
    
    % fix the filter index to fit the original filter specs cell array
    filterindex = sui.fileDialogue.refitFilterIndex(filterindex, vars, localParams);
end