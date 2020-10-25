function tf = isUiFigure(fig)
    if isempty(fig)
        tf = false;
        return;
    end
    
    tf = isgraphics(fig);
    tf(tf) = arrayfun(@(h) isa(h, 'matlab.ui.Figure'), fig(tf));
    tf(tf) = arrayfun(@(h) matlab.ui.internal.isUIFigure(h), fig(tf));
end

