classdef Tooltip < uix.Box & sui.IRedrawSuppressable
    %TOOLTIP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent)
        String;
        ForegroundColor;
    end
    
    properties
        RedrawListeners;
    end
    
    properties (Access=private)
        Owner;
        Label;
    end
    
    methods % property accessors
        function str = get.String(this)
            str = this.Label.String;
        end
        function set.String(this, str)
            this.Label.String = str;
        end
        function str = get.ForegroundColor(this)
            str = this.Label.ForegroundColor;
        end
        function set.ForegroundColor(this, str)
            this.Label.ForegroundColor = str;
        end
    end
    
    methods
        function this = Tooltip(owner, varargin)
            this.suppressDraw();
            this.RedrawListeners = {};
            this.Owner = owner;
            fig = ancestor(owner, 'figure');
            this.Parent = fig;
            
            container = owner.Parent;
            while ishandle(container) && ~eq(container, fig)
                if isa(container, 'sui.INotifyRedrawn')
                    this.RedrawListeners{end + 1} = addlistener(container, 'redrawn', @this.setDirty);
                end
                container = container.Parent;
            end
            
            this.Label = uicontrol(this, 'style', 'text', 'units', 'norm', 'position', [0 0 1 1]);
            uix.set(this, varargin{:});
            
            this.startDrawing();
        end
        
        function delete(this)
            if ~isvalid(this)
                return;
            end
            
            this.Owner = [];
            delete(this.Label);
            cellfun(@delete, this.RedrawListeners);
            this.RedrawListeners = {};
            
            delete@uix.Box(this);
        end
    end
    
    methods (Access=protected)
        function setDirty(this, ~, ~)
            this.Dirty = true;
        end
                
        function redraw(this)
            if this.StopRedraw
                return;
            end
            
            % Suppress redraw
            this.StopRedraw = true;
            
            this.copyTooltipPropertiesToLabel();
            
            ctl = this.Owner;
            x = sui.getAbsPos(ctl);
 
            mySize = sui.getSize(this, 'pixel');
            pad = this.Padding;
            offset = [pad, -mySize(2) - pad];
            sui.setPos(this, [x(1:2) + offset, mySize], 'pixel');
            
            % Reactivate redraw
            this.StopRedraw = false;
        end
        
        function copyTooltipPropertiesToLabel(this)
            this.Label.BackgroundColor = this.BackgroundColor;
        end
    end
end

