classdef ViewManager < mvvm.view.IViewManager
    % mvvm.view.ViewManager manages relations between views.
    % ViewManager uses dependency injection container to generate the
    % instances of new views. In practice view ids should be convertible to
    % IoC dependency names.
    
    properties (Access=protected)
        App appd.IApp;
        IoCContainer IoC.IContainer;
        SelfIoCContainerId = "ViewManager";
        ActiveViews containers.Map;
    end
    
    methods
        function this = ViewManager(app, viewManagerIoCContainerId)
            if nargin >= 2
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
        
        function view = start(this, id)
            vid = this.generateViewID(id);
            
            % create session views in a new session
            if this.isSessionView(vid)
                app = this.App.getApp();
                [~, session] = app.startSession();
                sessionViewManager = session.iocContainer.get(this.SelfIoCContainerId);
                view = sessionViewManager.startInOwnSession(vid);
            else
                view = this.startInOwnSession(vid);
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
        function view = startInOwnSession(this, vid)
            view = this.IoCContainer.get(vid.Type);
            
            this.ActiveViews(vid.toString()) = view;
            view.start();
        end
    end
end

