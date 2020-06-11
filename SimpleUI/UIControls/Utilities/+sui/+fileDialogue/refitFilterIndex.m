function filterindex = refitFilterIndex(filterindex, vars, localParams)
    % if should refit the filter index to fit the original indices
    if filterindex == 1
        filterindex = localParams.FilterIndex;
    elseif numel(vars) >= 1 && localParams.FilterIndex > 1
        filterIndexPerms = [localParams.FilterIndex, 1:localParams.FilterIndex-1, localParams.FilterIndex+1:size(vars{1},1)];
        filterindex = filterIndexPerms(filterindex);
    end
end

