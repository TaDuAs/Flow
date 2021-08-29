function tf = isChildOf(child, parent)
% find the parent matlab.ui.Figure of a ui component
    if isa(child, 'mvvm.view.IContainer')
        child = child.getContainerHandle();
    end

    tf = false;
    while ~isempty(child)
        if eq(child, parent)
            tf = true;
            return;
        end
        child = get(child,'Parent');
    end
end