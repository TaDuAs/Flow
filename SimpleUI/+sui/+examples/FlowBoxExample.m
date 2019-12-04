h.fig = figure(1);
clf();
h.title = annotation(h.fig,'textbox',...
    [0.02, 0.93, 0.9, 0.05],...
    'String',{'The shapes bellow are rendered only using matlab UI components',...
              'layed out using an sui.FlowBox',...
              'Play with the figure size to see the bricks flow adjusting'},...
    'FontSize', 10,...
    'FitBoxToText','on',...
    'EdgeColor', 'none');

h.main = sui.FlowBox(...
    'Parent', h.fig,...
    'Units', 'norm', ...
    'BasePosition', [0 0.15 1 0.5], ...
    'BackgroundColor', 'White', ...
    'Spacing', 5, ...
    'Padding', 15);

h.main.suppressDraw();

for i = 1:16
    bx(1) = uix.HBox('Units', 'pixel', 'Position', [0 0 20 25], 'BackgroundColor', 'Green', 'Parent', h.main);
    annotation(bx(1),'textbox',...
        [0 0 1 1],...
        'String',{num2str(i)},...
        'FontSize', 10,...
        'FitBoxToText','on',...
        'EdgeColor', 'none');
    bx(2) = uix.HBox('Units', 'pixel', 'Position', [0 0 30 30], 'BackgroundColor', 'Yellow', 'Parent', h.main);
    bx(3) = uix.HBox('Units', 'pixel', 'Position', [0 0 40 10], 'BackgroundColor', 'Red', 'Parent', h.main);
    bx(4) = uix.HBox('Units', 'pixel', 'Position', [0 0 50 40], 'BackgroundColor', 'Blue', 'Parent', h.main);
    
end
% clear bx i scrollSize

scrollSize = sui.getSize(h.main, 'pixel');
scroller.HorizontalOffsets = scrollSize(1);
scroller.VerticalOffsets = scrollSize(2);
h.main.startDrawing();

h.align = uibuttongroup(h.fig, 'Position', [0.02, 0.68, 0.2, 0.15]);
h.alignLeft = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0.7, 1, 0.3], 'Style', 'radiobutton', 'String', 'Left', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));
h.alignRight = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0.35, 1, 0.3], 'Style', 'radiobutton', 'String', 'Center', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));
h.alignRight = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0, 1, 0.3], 'Style', 'radiobutton', 'String', 'Right', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));

h.dir = uibuttongroup(h.fig, 'Position', [0.35, 0.68, 0.2, 0.15]);
h.ltr = uicontrol(h.dir, 'Units', 'norm', 'Position', [0, 0.7, 1, 0.3], 'Style', 'radiobutton', 'String', 'LTR', 'Callback', @(ctrl, arg) handleDirection(ctrl, arg, h));
h.rtl = uicontrol(h.dir, 'Units', 'norm', 'Position', [0, 0.35, 1, 0.3], 'Style', 'radiobutton', 'String', 'RTL', 'Callback', @(ctrl, arg) handleDirection(ctrl, arg, h));

h.vRowAlign = uibuttongroup(h.fig, 'Position', [0.7, 0.68, 0.2, 0.15]);
h.valignTop = uicontrol(h.vRowAlign, 'Units', 'norm', 'Position', [0, 0.7, 1, 0.3], 'Style', 'radiobutton', 'String', 'Top', 'Callback', @(ctrl, arg) handleVRowAlign(ctrl, arg, h));
h.valignCenter = uicontrol(h.vRowAlign, 'Units', 'norm', 'Position', [0, 0.35, 1, 0.3], 'Style', 'radiobutton', 'String', 'Center', 'Callback', @(ctrl, arg) handleVRowAlign(ctrl, arg, h));
h.valignBottom = uicontrol(h.vRowAlign, 'Units', 'norm', 'Position', [0, 0, 1, 0.3], 'Style', 'radiobutton', 'String', 'Bottom', 'Callback', @(ctrl, arg) handleVRowAlign(ctrl, arg, h));

function handleAlign(ctrl, arg, h)
    set(h.main, 'Align', get(ctrl,'String'));
end
function handleDirection(ctrl, arg, h)
    set(h.main, 'Direction', get(ctrl,'String'));
end
function handleVRowAlign(ctrl, arg, h)
    set(h.main, 'VRowAlign', get(ctrl,'String'));
end