classdef (Abstract) IContainer < mvvm.IControl
    
    properties (Dependent)
        % Direct parent of this ui container
        Parent mvvm.view.IContainer;
        
        % direct children of ui container
        Children;
    end
    
    methods
        function parent = get.Parent(this)
            parent = this.getParent();
        end
        function set.Parent(this, parent)
            this.setParent(parent);
        end
        
        function children = get.Children(this)
            children = this.getChildren();
        end
    end
    
    methods (Abstract)
        h = getContainerHandle(this);
        addChild(this, child);
        children = getChildren(this);
        parent = getParent(this);
        setParent(this, parent);
    end
    
    methods
        function tf = isEqualTo(this, arr)
            h = this.getContainerHandle();
            tf = false(size(arr));
            for i = 1:numel(arr)
                compareTo = arr(i);
                tf(i) = isequal(h, compareTo) || isequal(this, compareTo);
            end
        end
    end
end

