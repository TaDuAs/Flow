function [filename, pathname, filterindex] = getfile(varargin)
    [vars, localParams] = parseParams(varargin);
    
    if numel(vars) >= 1 && localParams.FilterIndex > 1
        filt = vars{1};
        
        % sort filter to use the previously chosen filter by default
        filt = filt([localParams.FilterIndex, 1:localParams.FilterIndex-1, localParams.FilterIndex+1:size(filt,1)], :);
        
        vars{1} = filt;
    end
    
    [filename, pathname, filterindex] = uigetfile(vars{:});
    
    if filename == 0
        return;
    end
    
    % if should refit the filter index to fit the original indices
    if filterindex == 1
        filterindex = localParams.FilterIndex;
    elseif numel(vars) >= 1 && localParams.FilterIndex > 1
        filterIndexPerms = [localParams.FilterIndex, 1:localParams.FilterIndex-1, localParams.FilterIndex+1:size(vars{1},1)];
        filterindex = filterIndexPerms(filterindex);
    end
end

function [vars, localParams] = parseParams(args)
    localParamNames = {'FilterIndex'};
    nvPairNames = {'MultiSelect'};
    
    % separate variables from name-value pair arguments
    [vars, nvpairs] = gen.varArgsNVPairs([nvPairNames, localParamNames], 0, args);
    
    % find all local parameters in the name-value pairs
    [~, localParamsIdx] = ismember('FilterIndex', nvpairs(1:2:end));
    
    % get local parameters
    localParamsIndex = [localParamsIdx;localParamsIdx+1];
    localArgs = nvpairs(localParamsIndex(:));
    localParams = parseLocalArgs(localArgs); % apply validation and default values
    
    % remove local parameters from nv pairs array
    nvpairs([localParamsIdx, localParamsIdx+1]) = [];
    
    % return arguments for builtin function
    vars = [vars, nvpairs];
end

function opt = parseLocalArgs(args)
    parser = inputParser();
    parser.FunctionName = 'sui.getfile';
    parser.CaseSensitive = false;
    
    % Histogram generation options
    parser.addOptional('FilterIndex', 1, @gen.valid.mustBeFinitePositiveRealScalar);
    
    parser.parse(args{:});
    
    opt = parser.Results;
    
end