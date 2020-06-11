function [filename, pathname, filterindex] = putfile(varargin)
% sui.putfile extends the functionality of uiputfile to also accept the
% filterindex argument returned from uiputfile, and sort the filter list
% accordingly to automatically select the item specified filter index.
%
% [filename, pathname, filterindex] = sui.putfile()
%   identical to uiputfile functionality
%
% [filename, pathname, filterindex] = sui.putfile(filter)
%   identical to uiputfile functionality
%
% [filename, pathname, filterindex] = sui.putfile(filter, title)
%   identical to uiputfile functionality
%
% [filename, pathname, filterindex] = sui.putfile(filter, title, defname)
%   identical to uiputfile functionality
%
% [filename, pathname, filterindex] = sui.putfile(___, [name, value])
%   also takes in optional parameters as name-value pairs
%       'FilterIndex' - the filter index returned by uigetfile. 
%           When specified, reorders the filters so that the previously 
%           selected filter will be selected by default. If not specified, 
%           the value is 1. The reordering of filter specs does not affect 
%           the returned filter index, that is, the index of the selected
%           filter is that of its location in the original cell array 
%           specified by the user. must be a positive finite integer scalar
%
    [vars, localParams] = sui.fileDialogue.parseExtenderArgs(varargin, {'MultiSelect'});
    
    % reorder filter specs so that the previously selected filter is
    % selected again
    vars = sui.fileDialogue.applyFilterIndex(vars, localParams);
    
    [filename, pathname, filterindex] = uiputfile(vars{:});
    
    if filename == 0
        return;
    end
    
    % fix the filter index to fit the original filter specs cell array
    filterindex = sui.fileDialogue.refitFilterIndex(filterindex, vars, localParams);
end