classdef Box < flow.RedrawAPIContainer & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        ...flow.mixin.PaddableComponent & ... % Padding is already implemented by GridLayout
        flow.mixin.ChildSpacingComponent
    %flow.Box  Box and grid base class
    %
    %  flow.Box is a base class for containers with spacing between
    %  contents.
    % 
    %  Original version Copyright 2009-2015 The MathWorks, Inc.
    %  $Revision: 1594 $ $Date: 2018-03-28 02:27:52 +1100 (Wed, 28 Mar
    %
    % Port to Web Component Framework by TADA
    
end % classdef