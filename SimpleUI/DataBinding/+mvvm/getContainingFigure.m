function fig = getContainingFigure(fig)
% find the parent matlab.ui.Figure of a ui component
    while ~isempty(fig) && ~isa(fig,'matlab.ui.Figure')
        fig = get(fig,'Parent');
    end
end