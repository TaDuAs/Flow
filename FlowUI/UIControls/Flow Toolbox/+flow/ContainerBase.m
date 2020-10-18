classdef (Abstract) ContainerBase < ...
        matlab.ui.container.GridLayout & ...
        flow.mixin.ControllerInitiator
    % flow.ContianerBase is a base class for extending Matlabs Web
    % Component Framework. Flow containers and containers ported from GUI 
    % Layout Toolbox will inherit this abstract class.
    %
    % Author - TADA, 2020
    
    % The obcious choice for super class was matlab.ui.container.internal.model.ContainerModel
    % However, as a ContainerModel extenssion, it cannot simply be added as 
    % a child to the uifigure. Another issue is matlab.ui.control.internal.model.mixin.ParentableComponent.
    % It appears that ParentableComponent is strongly coupled to certain 
    % types of containers, only allowing these three:
    %   matlab.ui.container.CanvasContainer
    %   matlab.ui.container.internal.model.AccordionPanel
    %   matlab.ui.container.GridLayout
    %
    % It occured to me then, that in order to serve as a generic container,
    % it must use one of these three as base class. CanvasContainer can
    % only be inheritted by inheriting uix.Container. In that case, it's
    % virtually impossible to add it into a uifigure. I didn't figure out
    % why yet, seems to be something to do with controller initiation.
    % Either way, if it was easily done, David Sampson would have ported
    % GUI Layout Toolbox already, so I left this approach behind.
    % This left only GridLayout as a viable base class, in which case, the
    % whole grid layout functionality needs to be overriden.
    % 
    
    % 
    % matlab.ui.internal.WebPanelController
    % matlab.ui.internal.componentframework.WebControllerFactory
    % matlab.ui.control.internal.controller.ComponentControllerFactoryManager
    % matlab.ui.control.internal.controller.ComponentControllerFactory
    
    methods (Access= public)
        function controller = createController(this, varargin)
%             controller = createController@matlab.ui.container.internal.model.ContainerModel(this, varargin{:});
            controller = createController@flow.mixin.ControllerInitiator(this, varargin{:});
        end
    end
    
    methods (Abstract, Access=protected)
        handleChildAdded(this, childAdded);
        handleChildRemoved(obj, childRemoved);
    end
    
        
    methods(Abstract, Access='public', Static=true, Hidden=true)
        varargout = doloadobj( hObj);
    end
    
    methods
        function controller = getControllerForcefully(this)
            controller = this.getController();
        end
    end
end

