classdef ViewManager < mvvm.view.IViewManager
    % mvvm.view.ViewManager manages relations between views.
    % ViewManager uses dependency injection container to generate the
    % instances of new views. In practice view ids should be convertible to
    % IoC dependency names.
    
    properties (Access=protected)
        App appd.IApp = appd.App.empty();
        IoCContainer IoC.IContainer = IoC.Container.empty();
        SelfIoCContainerId = "ViewManager";
        ActiveViews containers.Map;
    end
    
    methods
        function this = ViewManager(app, viewManagerIoCContainerId)
            if nargin >= 2 && ~isempty(viewManagerIoCContainerId)
                this.SelfIoCContainerId = viewManagerIoCContainerId;
            end
            this.App = app;
            this.IoCContainer = app.IocContainer;
            this.ActiveViews = containers.Map();
        end
        
        function delete(this)
            views = this.ActiveViews.Values;
            cellfun(@close, views);
            delete(this.ActiveViews);
        end
        
        function view = start(this, id, varargin)
            vid = this.generateViewID(id);
            
            % create session views in a new session
            if this.isSessionView(vid)
                app = this.App.getApp();
                [~, session] = app.startSession();
                sessionViewManager = session.iocContainer.get(this.SelfIoCContainerId);
                view = sessionViewManager.startInOwnSession(vid, varargin{:});
            else
                view = this.startInOwnSession(vid, varargin{:});
            end
        end
        
        function close(this, id)
            vid = toString(this.generateViewID(id));
            
            if this.ActiveViews.isKey(vid)
                view = this.ActiveViews(vid);
                view.close();
                this.ActiveViews.remove(vid);
            end
        end
        
        function show(this, id)
            vid = toString(this.generateViewID(id));
            
            if this.ActiveViews.isKey(vid)
                view = this.ActiveViews(vid);
                view.show();
            end
        end
        
        function ownerView = getOwnerView(this, view)
            % hierarchically finds the lowest level view which contains the
            % specified view
            viewContainer = view.getContainerHandle();
            h = viewContainer.Parent;
            ownerView = mvvm.view.Window.empty();
            activeViewList = cellfun(@(v) v, this.ActiveViews.Values);
            activeHandles = arrayfun(@getContainerHandle, activeViewList);
            
            while ~isempty(h) && isvalid(h)
                isViewHandle = activeHandles == h;
                
                if any(isViewHandle)
                    ownerView = activeViewList(isViewHandle);
                    return;
                end
            end
        end
        
        function register(this, view)
            vid = view.Id;
            if ~this.ActiveViews.isKey(vid)
                this.ActiveViews(vid) = view;
            end
        end
    end
    
    methods (Access=protected)
        function vid = generateViewID(this, id)
            if isa(id, 'mvvm.view.ViewID')
                vid = id;
            elseif gen.isSingleString(id)
                vid = mvvm.view.ViewID(id);
            else
                throw(MException('mvvm:view:ViewManager:InvalidViewId', 'View id must be a string or a mvvm.view.ViewID'));
            end
        end
        
        function tf = isSessionView(this, vid)
            viewTypeName = this.IoCContainer.getType(vid.Type);
            
            viewType = meta.class.fromName(viewTypeName);
            
            % check if the view represented by the specified dependency id 
            % is a session view
            tf = viewType <= ?mvvm.view.MainSessionView;
        end
    end
    
    methods (Access={?mvvm.view.ViewManager})
        function view = startInOwnSession(this, vid, owner)
            svid = vid.toString();
            view = this.IoCContainer.get(vid.Type, '@ViewManager', this, '@Id', strcat("$", svid));
            
            this.ActiveViews(svid) = view;
            view.start();
        end
    end
end

