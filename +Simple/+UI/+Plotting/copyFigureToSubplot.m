function copyFigureToSubplot(originalFig, fig, subplotCoordinates)
            Simple.obsoleteWarning('Simple.UI');
    if ischar(originalFig)
        originalFig = openfig(originalFig, 'reuse');
    end
    % get handle to axes of figure
    axOriginal = gca;

    figure(fig);
    
    % create and get handle to the subplot axes
    if isnumeric(subplotCoordinates)
        s1 = subplot(subplotCoordinates);
    else
        s1 = subplotCoordinates;
    end
    
    numYAxes = length(axOriginal.YAxis);
    if numYAxes > 1
        yyaxis(axOriginal.YAxisLocation);
    end
    for i = 1:numYAxes
        % Flip Y Axes
        if i > 1
            if strcmp(axOriginal.YAxisLocation, 'right')
                newYAxisSide = 'left';
            else
                newYAxisSide = 'right';
            end
            figure(originalFig);
            yyaxis(newYAxisSide);
            figure(fig);
            yyaxis(newYAxisSide);
        end
        
        yax = axOriginal.YAxis(i);
        
        % copy children to new parent axes i.e. the subplot axes
        copyobj(get(axOriginal,'children'),s1); 

        newAxis = gca;
        newYAx = newAxis.YAxis(i);

        % Set y properties
        newYAx.Color = yax.Color;
        newYAx.Limits = yax.Limits;
        newYAx.Label.String = yax.Label.String;
    end
    
    % Set x properties
    newAxis.XAxis.Color = axOriginal.XAxis.Color;
    newAxis.XAxis.Limits = axOriginal.XAxis.Limits;
    xlabel(axOriginal.XAxis.Label.String);
    
    % Set other properties
    legend(axOriginal.Legend.String);
    
    
    % Close original figure
    close(originalFig);
end

