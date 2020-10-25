function axh = gca(h)
    if nargin < 1 || isempty(h)
        axh = gca();
    elseif isnumeric(h)
        % if the user sent a figure id, use classic figure and then use gca
        % to get the active axes or populate the figure with an axes object
        fig = figure(h);
        axh = gca(fig);
    elseif isa(h, 'matlab.graphics.axis.Axes') || isa(h, 'matlab.ui.control.UIAxes')
        % if the user sent an axes or uiaxes object, use that
        axh = h;
    elseif sui.isUiFigure(h)
        % with uifigure, try to find a uiaxes object
        axh = findobj(h, 'type', 'axes');
        if isempty(axh)
            % if none exist, generate a new axes object
            axh = uiaxes(h);
        else
            % use the available uiaxes from the specified figure
            axh = axh(1);
        end
    elseif isa(h, 'matlab.ui.Figure')
        % with classic figure, use gca, which will generate an axes
        % object if none exist
        figure(h);
        axh = gca(h);
    elseif isa(h, 'matlab.graphics.Graphics')
        % with ui containers, try to find an axes/uiaxes object
        axh = findobj(h, 'type', 'axes');
        if isempty(axh)
            % if none exist, generate a new axes object according to the
            % type of figure
            fig = findobj(h, 'type', 'figure');
            if sui.isUiFigure(fig)
                axh = uiaxes(h);
            else
                axh = axes(h);
            end
        else
            % use the available uiaxes from the specified figure
            axh = axh(1);
        end
    else
        throw(MException('sui:gca:InvalidHandleType', 'sui.gca only takes in axes, uiaxes, figure, uifigure, ui containers or numeric index of the figure'));
    end
end

