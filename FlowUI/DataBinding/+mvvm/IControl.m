classdef (Abstract) IControl < handle
    % List of methods a ui control should implement in order to be data
    % bound using mvvm toolbox
    
    properties (GetAccess=private, SetAccess=private)
        Id_;
    end
    
    properties (Dependent)
        Id;
    end
    
    methods (Abstract)
        parent = ancestor(this, type);
        
        h = findobj(this, varargin);
    end
    
    % properties
    methods
        function id = get.Id(this)
            id = this.getControlId();
        end
        function set.Id(this, id)
            this.setControlId(id);
        end
    end
    
    methods
        function tf = isEqualTo(this, arr)
            tf = false(size(arr));
            for i = 1:numel(arr)
                compareTo = arr(i);
                tf(i) = isequal(this, compareTo);
            end
        end
    end
    
    methods (Access=protected)
        function id = getControlId(this)
            id = this.Id_;
        end
        
        function setControlId(this, id)
            this.Id_ = id;
        end
    end
end

