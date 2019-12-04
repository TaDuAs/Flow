h.fig = figure(1);
clf();
set(h.fig, 'Position', get( groot, 'Screensize' ) + repelem([60 -150],1,2));

h.title = annotation(h.fig,'textbox',...
    [0.02, 0.93, 0.9, 0.05],...
    'String',{'The sui.Img control loads the correct image and draws it on an invisible axes object',...
              'By setting the MaxSize property of Img instead of Position,',...
              'the size of the image will be adjusted to fit the original image ratio'},...
    'FontSize', 10,...
    'FitBoxToText','on',...
    'EdgeColor', 'none');

h.scroll = uix.ScrollingPanel( 'Parent', h.fig, 'Position', [0.125 0.1 0.75 0.65] );
h.main = sui.StackBox('Parent', h.scroll,...
    'Units', 'norm',...
    'BasePosition', [0.05 0 0.98 1],...
    'BackgroundColor', 'White', ...
    'Spacing', 5, ...
    'Padding', 15, ...
    'Align', 'center');
h.main.suppressDraw();
h.flowResizeListener = h.main.addlistener('SizeChanged', @(src, arg) flowResize(src, arg, h));
h.img(1) = sui.Img('Units', 'pixels', 'IsCached', true, 'MaxSize', [250 200], 'Path', 'autumn.tif', 'Parent', h.main);
h.img(2) = sui.Img('Units', 'pixels', 'IsCached', true, 'Position', [0 0 300 100], 'Path', 'autumn.tif', 'Parent', h.main);
h.img(3) = sui.Img('Units', 'pixels', 'IsCached', true, 'MaxSize', [100 50], 'Path', 'autumn.tif', 'Parent', h.main);
h.img(4) = sui.Img('Units', 'pixels', 'IsCached', true, 'MaxSize', [500 500], 'Path', 'autumn.tif', 'Parent', h.main);

h.align = uibuttongroup(h.fig, 'Position', [0.02, 0.77, 0.2, 0.1]);
h.autumn = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0.7, 1, 0.3], 'Style', 'radiobutton', 'String', 'autumn.tif', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));
h.saturn = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0.35, 1, 0.3], 'Style', 'radiobutton', 'String', 'saturn.png', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));
h.snowflakes = uicontrol(h.align, 'Units', 'norm', 'Position', [0, 0, 1, 0.3], 'Style', 'radiobutton', 'String', 'snowflakes.png', 'Callback', @(ctrl, arg) handleAlign(ctrl, arg, h));

flowResize([],[],h);
h.main.startDrawing();

function handleAlign(ctrl, arg, h)
    set(h.img, 'Path', get(ctrl,'String'));
end
function flowResize(src, arg, h)
    scrollSize = sui.getSize(h.main, 'pixel');
    scroller = h.scroll;
    
    if scrollSize(1) ~= scroller.Widths
        scroller.Widths = scrollSize(1);
    end
    if scrollSize(2) ~= scroller.Heights
        scroller.Heights = scrollSize(2);
    end
end