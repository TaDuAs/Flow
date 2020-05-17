classdef ViewList < mvvm.view.IViewManager
    %VIEWLIST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Views lists.Map;
        ViewBuilders lists.Map;
        OwnerView mvvm.view.IView = mvvm.view.Window.empty();
        Container;
        Params;
    end
    
    methods
        function this = ViewList(container, ownerView, varargin)
            this.ViewBuilders = lists.Map();
            this.Views = lists.Map();
            this.Container = container;
            
            if nargin >= 2
                this.OwnerView = ownerView;
            end
            
            if nargin >= 3
                this.Params = varargin;
            else
                this.Params = {};
            end
        end
        
        function view = start(this, id)
            if isa(id, 'mvvm.view.ViewID')
                id = id.toString();
            end
            
            if this.Views.isKey(id)
                view = this.Views.getv(id);
                
                if view.Status == mvvm.view.ViewStatus.NotActivated
                    view.start();
                elseif view.Status == mvvm.view.ViewStatus.Closed
                    this.Views.remove(id);
                    view = this.start(id);
                end
            elseif this.ViewBuilders.isKey(id)
                builder = this.ViewBuilders(id);
                params = this.Params;
                if ~isempty(this.OwnerView)
                    params = [{this.OwnerView}, params];
                end
                view = builder(this.Container, params{:});
                this.Views(id) = view;
                view.start();
            else
                throw(MException('sui:ViewList:UnknownView', 'There is no registered view with id %s', id));
            end
        end
        
        function register(this, view, id)
            if isa(view, 'mvvm.view.IView')
                if nargin < 2
                    id = view.Id;
                end
                this.Views(id) = view;
            else
                if isa(id, 'mvvm.view.ViewID')
                    id = id.toString();
                end
                
                assert(isa(view, 'function_handle'), 'View builder must be a function handle');
                
                this.ViewBuilders(id) = view;
            end
        end
        
        function close(this, id)
            if isa(id, 'mvvm.view.ViewID'); id = id.toString(); end
            
            if this.Views.isKey(id)
                view = this.Views(id);
                view.close();
                this.Views.remove(id);
            end
        end
        
        function view = show(this, id)
            view = this.start(id);
            view.show();
        end
        
        function ownerView = getOwnerView(this, view)
            ownerView = this.OwnerView;
        end
    end
end

