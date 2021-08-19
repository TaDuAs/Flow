classdef IUIControl < mvvm.IControl
    methods (Access=protected)
        function id = getControlId(this)
            id = this.Tag;
        end
        
        function setControlId(this, id)
            this.Tag = id;
        end
    end
end

