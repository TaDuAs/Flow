classdef StackPanelLayout < mvvm.view.ContainerControl
    %FLOWGRIDLAYOUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        AddChildEventListener event.listener;
        RemoveChildEventListener event.listener;
    end
    
    methods
        function this = StackPanelLayout(varargin)
            this@mvvm.view.ContainerControl(uigridlayout(varargin{:}));
            this.ControlHandle.ColumnWidth = {'1x'};
            this.ControlHandle.RowHeight = {'fit', '1x'};
            
            this.AddChildEventListener = this.ControlHandle.addlistener('ChildAdded', @this.onChildAdded);
            this.RemoveChildEventListener = this.ControlHandle.addlistener('ChildRemoved', @this.onChildRemoved);
        end
        
        function delete(this)
            delete(this.AddChildEventListener);
            delete(this.RemoveChildEventListener);
        end
    end
    
    methods (Access=private)
        function onChildAdded(this, grid, e)
            this.onChildrenChanged();
        end
        
        function onChildRemoved(this, grid, e)
            this.onChildrenChanged();
        end
        
        function onChildrenChanged(this)
            grid = this.ControlHandle;
            for i = 1:numel(grid.Children)
                currChild = grid.Children(i);
                currChild.Layout.Row = i;
            end
            
            grid.RowHeight = [repmat({'fit'}, 1, numel(grid.Children)), {'1x'}];
        end
    end
end

