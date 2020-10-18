function [vars, extenderArgs] = splitExtenderArgs(args, extenderParamNames, innerParamNames)
% parseExtenderParams parses function parameters and separates parameters
% for extending function from those of extended function

    % separate variables from name-value pair arguments
    [vars, nvpairs] = gen.varArgsNVPairs([innerParamNames, extenderParamNames], 0, args);
    
    % find all local parameters in the name-value pairs
    [extenderParamsExistFlags, extenderParamsIdx] = ismember(extenderParamNames, nvpairs(1:2:end));
    
    % get local parameters
    extenderParamsIdx = extenderParamsIdx(extenderParamsExistFlags);
    localParamsIndex = [extenderParamsIdx;extenderParamsIdx+1];
    extenderArgs = nvpairs(localParamsIndex(:));
    
    % remove local parameters from nv pairs array
    nvpairs(localParamsIndex(:)) = [];
    
    % return arguments for builtin function
    vars = [vars, nvpairs];
end
