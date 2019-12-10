function tf = isChildOf(child, parent)
% find the parent matlab.ui.Figure of a ui component
    tf = false;
    while ~isempty(child)
        if eq(child, parent)
            tf = true;
            return;
        end
        child = get(child,'Parent');
    end
end