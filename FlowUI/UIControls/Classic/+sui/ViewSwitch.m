classdef ViewSwitch < uix.Box
    properties
        ViewManager mvvm.view.IViewManager = sui.ViewList.empty();
        OwnerView mvvm.view.IView = mvvm.view.Window.empty();
        ActiveViewId mvvm.view.ViewID;
        ActiveView mvvm.view.IView = mvvm.view.ComponentView.empty();
        DeactivateInactiveViews logical = true;
    end
    
    methods 
        function set.ActiveViewId(this, value)
            if gen.isSingleString(value)
                value = mvvm.view.ViewID(value);
            end
            
            if numel(this.ActiveViewId) ~= numel(value) || (~isempty(this.ActiveViewId) && ~isempty(value) && this.ActiveViewId ~= value)
                this.ActiveViewId = value;
                this.Dirty = true;
            end
        end
    end
    
    methods
        function this = ViewSwitch(varargin)
            uix.set(this, varargin{:});
            
            if isempty(this.ViewManager)
                this.ViewManager = sui.ViewList(this.Parent, this.OwnerView);
            end
        end
        
        function add(this, id, item)
            this.ViewManager.register(item, id);
        end
    end
    
    methods (Access=protected)
        function redraw(this)
            if ~isempty(this.ActiveViewId)
                % if new view is different from previous one, hide previous
                % active view
                if ~isempty(this.ActiveView) && ~isequal(this.ActiveViewId, this.ActiveView.Id)
                    this.ActiveView.hide();
                    
                    if this.DeactivateInactiveViews
                        this.ActiveView.sleep();
                    end
                end
                
                this.ActiveView = this.ViewManager.show(this.ActiveViewId);
                this.ActiveView.wake();
            end
        end
    end
end