function [vars, nvpairs] = varArgsNVPairs(nvPairNames, nMandatoryVars, argArray)
    nargs = numel(argArray);
    nvpairs = {};
    
    if mod(nargs, 2) == 0 
        maybePairs = 1:2:nargs-1;
    else
        maybePairs = 2:2:nargs-1;
    end
    
    % skip mandatory variables
    maybePairs = maybePairs(maybePairs > nMandatoryVars);
    
    % find name-value pairs
    lastVariableIndex = nargs;
    for i = maybePairs
        if gen.isSingleString(argArray{i}) && ismember(argArray{i}, nvPairNames)
            % trim vars at the index of the first nv pair
            lastVariableIndex = i - 1;
            
            % extract nv pairs
            nvpairs = argArray(i:end);
        end
    end
    
    % extract vars
    vars = argArray(1:lastVariableIndex);
end

