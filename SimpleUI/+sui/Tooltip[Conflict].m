classdef Tooltip < uix.Box
    %TOOLTIP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Dependent)
        String;
        ForegroundColor;
    end
    
    properties
        Owner;
    end
    
    properties (Access=private)
        label;
    end
    
    methods % property accessors
        function str = get.String(this)
            str = this.label.String;
        end
        function set.String(this, str)
            this.label.String = str;
        end
        function str = get.ForegroundColor(this)
            str = this.label.ForegroundColor;
        end
        function set.ForegroundColor(this, str)
            this.label.ForegroundColor = str;
        end
    end
    
    methods
        function this = Tooltip(owner, varargin)
            this.Owner = owner;
            this.Parent = ancestor(owner, 'figure');
            this.label = uicontrol(this, 'style', 'text', 'units', 'norm', 'position', [0 0 1 1]);
            uix.set(this, varargin{:});
            this.label.BackgroundColor = this.BackgroundColor;
        end
    end
    
    methods (Access=protected)
        function redraw(this)
            this.label.BackgroundColor = this.BackgroundColor;
            
            ctl = this.Owner;
            x = zeros(1,4);
            fig = ancestor(ctl, 'figure');
            while ishandle(ctl) && ~eq(ctl, fig)
                x = x + sui.getPos(ctl, 'pixel');
                ctl = ctl.Parent;
            end
 
            mySize = sui.getSize(this, 'pixel');
            offset = [this.Padding, -mySize(2)-this.Padding];
            sui.setPos(this, [x(1:2) + offset, mySize], 'pixel')
        end
    end
end

