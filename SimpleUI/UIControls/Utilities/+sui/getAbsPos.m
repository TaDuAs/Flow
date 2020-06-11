function pos = getAbsPos(ctl)
    pos = zeros(1,4);
    fig = ancestor(ctl, 'figure');
    while ishandle(ctl) && ~eq(ctl, fig)
        pos = pos + sui.getPos(ctl, 'pixel');
        ctl = ctl.Parent;
    end
end

