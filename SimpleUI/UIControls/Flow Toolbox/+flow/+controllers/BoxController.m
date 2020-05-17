classdef BoxController < matlab.ui.internal.componentframework.WebContainerController
% flow.controllers.BoxController is a generic box controller class.

% appdesservices.internal.interfaces.controller.mixin.ViewPropertiesHandler
% matlab.ui.control.internal.view.ComponentProxyViewFactoryManager
% matlab.ui.control.internal.view.ComponentProxyViewFactory

% TODO: Understand proxy view
% TODO: Understand view hierarchy
% TODOL Understand 
    properties
        PositionBehavior;
        ScrollableBehavior;
    end

    methods
        function this = BoxController(varargin)
            this@matlab.ui.internal.componentframework.WebContainerController(varargin{:});
            propMgrService = this.PropertyManagementService;
            
            this.PositionBehavior = matlab.ui.internal.componentframework.services.optional.PositionBehaviorAddOn(propMgrService);
            
            this.ScrollableBehavior = matlab.ui.internal.componentframework.services.optional.ScrollableBehaviorAddOn(propMgrService);
       
        end
    end
    
    methods
        function newPosValue = updatePosition(this)
            oneOriginPosValue = this.Model.Position;
            newPosValue = this.PositionBehavior.updatePositionInPixels(oneOriginPosValue);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      updateScrollLocation
        %
        %  Description: Method invoked when the model's scroll location changes. 
        %
        %  Inputs :     None.
        %  Outputs:     
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function newScrollLocation = updateScrollLocation( this )
            newScrollLocation = this.scrollableBehavior.updateScrollLocation( this.Model );
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      scrollTo
        %
        %  Description: Requests that the client scroll to a named location such
        %               as the top, bottom, left, or right.
        %
        %  Inputs :     'top', 'bottom', 'left', 'right'
        %  Outputs:     None
        %
        function scrollTo( this, varargin )
            this.scrollableBehavior.scrollTo( this, varargin{:} );
        end
    end
    
    methods (Access=protected)
        function defineViewProperties( this )

            % Add view properties specific to the panel, then call super
            this.PropertyManagementService.defineViewProperty( 'Visible' );
            this.PropertyManagementService.defineViewProperty( 'BackgroundColor' );
            this.PropertyManagementService.defineViewProperty( 'Position' );
            defineViewProperties@matlab.ui.internal.componentframework.WebContainerController( this );
        end
        
        function varargout = createView(this, varargin)
            varargout = cell(1, nargout(createView@matlab.ui.internal.componentframework.WebContainerController));
            varargout{:} = createView@matlab.ui.internal.componentframework.WebContainerController(this, varargin{:});
        end
    end
    
    methods
        function getPropertyNamesToProcessAtRuntime(this)
            % TODO: understand what this method is
        end
        
        function getExcludedPropertyNamesToProcessAtRuntime(this)
            % TODO: understand what this method is
        end
    end
end

