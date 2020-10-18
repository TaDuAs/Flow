function vars = applyFilterIndex(vars, localParams)
    if numel(vars) >= 1 && localParams.FilterIndex > 1
        filt = vars{1};
        
        % sort filter to use the previously chosen filter by default
        filt = filt([localParams.FilterIndex, 1:localParams.FilterIndex-1, localParams.FilterIndex+1:size(filt,1)], :);
        
        vars{1} = filt;
    end
end

