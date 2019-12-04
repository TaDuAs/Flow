function varargout = zoomginput(varargin)
% zoomginput activates ginput and allows zooming in/out of the active axis
% using the mouse wheel.
% scroll up to zoom in, scroll down to zoom out.
% all other functionality is identical to ginput.
%
% Author: TADA 2019
    scrollListener = addlistener(gcf(), 'WindowScrollWheel', @onScroll);
    
    try
        varargout = cell(1, max(nargout, 1));
        [varargout{:}] = ginput(varargin{:});
        delete(scrollListener);
    catch ex
        delete(scrollListener);
        ex.rethrow();
    end
end

function onScroll(src, edata)
    % calculate zoom factor
    defaultFactor = 1.1;
    factor = (defaultFactor * abs(edata.VerticalScrollCount))^sign(edata.VerticalScrollCount);
    
    sui.zoomCursor(gca, factor);
end