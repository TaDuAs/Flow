h.fig = figure();
h.title = annotation(h.fig,'textbox',...
    [0.02, 0.93, 0.9, 0.05],...
    'String',{'The boxes below are layed out one per row using an sui.StackBox'},...
    'FontSize', 10,...
    'FitBoxToText','on',...
    'EdgeColor', 'none');

h.main =  sui.StackBox('Parent', h.fig, 'Units', 'norm', 'BasePosition', [0 0.25 1 0.5], 'BackgroundColor', 'White', 'Spacing', 5, 'Padding', 15);

for i = 1:2
    uix.HBox('Units', 'pixel', 'Position', [0 0 20 25], 'BackgroundColor', 'Green', 'Parent', h.main);
    uix.HBox('Units', 'pixel', 'Position', [0 0 30 40], 'BackgroundColor', 'Yellow', 'Parent', h.main);
    uix.HBox('Units', 'pixel', 'Position', [0 0 40 50], 'BackgroundColor', 'Red', 'Parent', h.main);
    uix.HBox('Units', 'pixel', 'Position', [0 0 50 10], 'BackgroundColor', 'Blue', 'Parent', h.main);
end



h.align = uibuttongroup(h.fig, 'Position', [0.02, 0.77, 0.2, 0.15]);
h.alignLeft = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0.7, 1, 0.3], 'Style', 'radiobutton', 'String', 'Left', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));
h.alignLeft = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0.35, 1, 0.3], 'Style', 'radiobutton', 'String', 'Center', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));
h.alignRight = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0, 1, 0.3], 'Style', 'radiobutton', 'String', 'Right', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));

function handleAlign(ctrl, arg, h)
    set(h.main, 'Align', get(ctrl,'String'));
end