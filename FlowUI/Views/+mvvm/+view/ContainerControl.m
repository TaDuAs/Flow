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
            h = this.getControlHandle(child);
            h.Parent = this.ControlHandle;
        end
        
        function children = getChildren(this)
            children = this.ControlHandle.Children;
        end
        
        function parent = getParent(this)
            parent = this.ControlHandle.Parent;
        end
        
        function setParent(this, parent)
            h = this.getControlHandle(parent);
            this.ControlHandle.Parent = h;
        end
        
        function delete(this)
            if ishandle(this.ControlHandle)
                delete(this.ControlHandle);
            end
        end
    end
    
    methods (Access=protected)
        function h = getControlHandle(~, control)
        % Gets the control handle from a control object when it is not
        % known whether the object is an actual matlab control handle or a 
        % mvvm.view.IContainer wrapper object
        
            if isa(control, 'mvvm.view.IContainer')
                h = control.getContainerHandle();
            else
                h = control;
            end
        end
        
        function id = getControlId(this)
            h = this.getContainerHandle();
            id = h.Tag;
        end
        
        function setControlId(this, id)
            h = this.getContainerHandle();
            h.Tag = id;
        end
    end
end

