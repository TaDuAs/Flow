classdef ContainerControl < mvvm.view.IContainer
    properties (Access=protected)
        ControlHandle;
    end
    
    methods
        function this = ContainerControl(control)
            this.ControlHandle = control;
        end
        
        function h = getContainerHandle(this)
            h = [this.ControlHandle];
        end
        
        function parent = ancestor(this, type)
            if nargin >= 2
                parent = ancestor([this.ControlHandle], type);
            else
                parent = ancestor([this.ControlHandle]);
            end
        end
        
        function h = findobj(this, varargin)
            h = findobj(this.ControlHandle, varargin{:});
        end
        
        function addChild(this, child)
            if isa(child, 'mvvm.view.IContainer')
                h = child.getContainerHandle();
            else
                h = child;
            end
            
            h.Parent = this.ControlHandle;
        end
        
        function children = getChildren(this)
            children = this.ControlHandle.Children;
        end
        
        function parent = getParent(this)
            parent = this.ControlHandle.Parent;
        end
        
        function setParent(this, parent)
            if isa(parent, 'mvvm.view.IContainer')
                h = parent.getContainerHandle();
            else
                h = parent;
            end
            
            this.ControlHandle.Parent = h;
        end
        
        function delete(this)
            if ishandle(this.ControlHandle)
                delete(this.ControlHandle);
            end
        end
    end
end

