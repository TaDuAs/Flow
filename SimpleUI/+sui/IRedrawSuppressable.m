classdef (Abstract) IRedrawSuppressable < handle
    
    properties
        StopRedraw;
    end
    
    methods (Abstract, Access=protected)
        setDirty(this);
    end
    
    methods
        function suppressDraw(this)
            this.StopRedraw = true;
        end
        
        function startDrawing(this)
            this.StopRedraw = false;
            this.setDirty();
        end
    end
end

