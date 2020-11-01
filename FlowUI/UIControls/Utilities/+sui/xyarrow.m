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
% ah = xyarrow(axes, ___)
%   adds an arrow annotation to the specified axes handle.
% Input:
%   ax - The axes object on which to overlay the arrow annotation
% Output:
%   ah - the arrow annotation handle
%
% ah = xyarrow(figure, ___)
%   adds an arrow annotation to the active axes handle within the specified
%   figure. If no axes object exists, one will be created.
% Input:
%   figure - The figure handle to which add the arrow annotation. The
%            annotation position will be calculated according to the x-y
%            axes of the active axes object within this figure.
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
    
    if isa(varargin{1}, 'matlab.graphics.axis.Axes') || isa(varargin{1}, 'matlab.ui.Figure')
        anoinput = [varargin(1), {'arrow'}, varargin(2:end)];
    else
        anoinput = [{'arrow'}, varargin];
    end
    
    ah = sui.xyannotation(anoinput{:});
end

