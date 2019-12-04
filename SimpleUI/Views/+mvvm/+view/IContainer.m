classdef (Abstract) IContainer < mvvm.IControl
    
    properties (Dependent)
        Parent mvvm.view.IContainer = mvvm.view.ContainerControl.empty();
        Children;
    end
    
    methods
        function parent = Parent.get(this)
            parent = this.getParent();
        end
        function Parent.set(this, parent)
            this.setParent(parent);
        end
        function children = Children.get(this)
            children = this.getChildren();
        end
    end
    
    methods (Abstract)
        h = getContainerHandle(this);
        addChild(this, child);
        children = getChildren(this);
        parent = getParent(this);
        setParent(this, parent);
        view = getOwnerView(this);
    end
end

