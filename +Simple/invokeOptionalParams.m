function varargout = invokeOptionalParams(handle, params)
%INVOKEOPTIONALPARAMS Summary of this function goes here
%   Detailed explanation goes here
            Simple.obsoleteWarning();
    import Simple.*;

    input = cell(1, 0);
    
    if nargin >= 2
        [~, sortedIndices] = sort([params.order]);
        params = params(sortedIndices);
        for i = 1:length(params)
            currParam = params(i);
            if ~isempty(currParam.value) || currParam.sendIfEmpty
                input{length(input) + 1} = currParam.value;
            end
        end
    end
    
    if nargout > 0
        varargout = cell(1, nargout);
    elseif nargout(handle) > 0
        varargout = cell(1, 1);
    else
        varargout = {};
    end
    [varargout{:}] = handle(input{:});
end

