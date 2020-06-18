function ah = xyarrow(varargin)
% sui.xyarrow creates an arrow annotation object with the x-y coordinates
% of a specific axes handle.
% 
% ah = xyarrow(x, y)
%   adds an arrow annotation to the current active axes using the gca
%   function. If no axes object exists, one will be created.
% Input:
%   x - A 2 element vector containing the x-coordinates of the arrow within
%       the current axes object, of the form [xstart xend]
%   y - A 2 element vector containing the y coordinates of the arrow within
%   	the current axes object, of the form [ystart yend]
% Output:
%   ah - the arrow annotation handle
%
% ah = xyarrow(axes, x, y)
%   adds an arrow annotation to the specified axes handle.
% Input:
%   ax - The axes object on which to overlay the arrow annotation
%   x - A 2 element vector containing the x-coordinates of the arrow within
%       the current axes object, of the form [xstart xend]
%   y - A 2 element vector containing the y coordinates of the arrow within
%   	the current axes object, of the form [ystart yend]
% Output:
%   ah - the arrow annotation handle
%
% ah = xyarrow(figure, x, y)
%   adds an arrow annotation to the active axes handle within the specified
%   figure. If no axes object exists, one will be created.
% Input:
%   figure - The figure handle to which add the arrow annotation. The
%            annotation position will be calculated according to the x-y
%            axes of the active axes object within this figure.
%   x - A 2 element vector containing the x-coordinates of the arrow within
%       the current axes object, of the form [xstart xend]
%   y - A 2 element vector containing the y coordinates of the arrow within
%   	the current axes object, of the form [ystart yend]
% Output:
%   ah - the arrow annotation handle
%
% ah = xyarrow(___, [Name, Value])
%   Also takes in extra arguments to pass over to annotation. Use any
%   properties you usually pass to the builtin annotation function.
%
% Author - TADA, 2020
%

    assert(nargin >= 2, 'not enough input arguments. expecting at least x and y position vectors');
    
    if isa(varargin{1}, 'matlab.graphics.axis.Axes')
        ax = varargin{1};
        x = varargin{2};
        y = varargin{3};
        firstArgIdx = 4;
    elseif isa(varargin{1}, 'matlab.ui.Figure')
        ax = gca(varargin{1});
        x = varargin{2};
        y = varargin{3};
        firstArgIdx = 4;
    else
        x = varargin{1};
        y = varargin{2};
        firstArgIdx = 3;
        ax = gca();
    end
    
    % this is the container which will be the parent of the annotation
    % object
    container = ax.Parent;
    
    assert(numel(x) == 2 && isnumeric(x), 'x must be a two element vector which represents the x start and end coordinates of the arrow');
    assert(numel(y) == 2 && isnumeric(y), 'y must be a two element vector which represents the y start and end coordinates of the arrow');
    
    % get absolute position of axes in pixels
    axPos = getPos(ax, 'pixels');
    
    % get size of axes in pixels
    axSize = getSize(ax, 'pixels');
    
    % get the axes x-y limits
    xlims = xlim(ax);
    ylims = ylim(ax);
    
    % calculate the conversion factor between x-y units and pixels
    x2pix = axSize(1)/range(xlims);
    y2pix = axSize(2)/range(ylims);
    
    % calculate the pixel position of the arrow
    xpos = (x - xlims(1)) * x2pix + axPos(1);
    ypos = (y - ylims(1)) * y2pix + axPos(2);
    
    % normalize x-y positions to the size of the container
    containerSize = getSize(container, 'pixels', 'inner');
    xposNorm = xpos / containerSize(1);
    xposNorm(xposNorm > 1) = 1;
    xposNorm(xposNorm < 0) = 0;
    yposNorm = ypos / containerSize(2);
    yposNorm(yposNorm > 1) = 1;
    yposNorm(yposNorm < 0) = 0;
    
    % create the annotation object
    ah = annotation(container, 'arrow', xposNorm, yposNorm, varargin{firstArgIdx:end});
end

