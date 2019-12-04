classdef AppSession < appd.IApp
    % App class decorator.
    % Implement a session persistence on the Application by overriding the
    % Context property, and returning a session-key based instance
    % To access application-context PersistenceContainer access
    % appd.App.Context
    % directly.
    
    properties
        SessionKey = [];
    end
    
    properties (Access=private)
        App appd.IApp = appd.App.empty();
        SessionManager appd.SessionManager;
    end
    
    properties (Hidden, Dependent)
        PersistenceContainer;
    end
    
    properties (GetAccess=public, SetAccess=protected)
        % Application status
        Status appd.AppStatus = appd.AppStatus.NotAvailable;
    end
    
    properties (GetAccess=public, SetAccess=private, Dependent)
        % Dependency injection container
        IocContainer IoC.IContainer = IoC.Container.empty();
        
        % Application context object - for application-wide state management
        Context appd.AppContext;
        
        % Application-wide mediator class
        Messenger appd.MessagingMediator;
    end
    
    methods % Property accessors
        function app = getApp(this)
            app = this.App;
        end
        
        function m = get.Messenger(this)
            m = this.App.Messenger;
        end
        function set.Messenger(~, ~)
            throw(MException('AppSession:InvalidOperation', 'Can''t set Messenger property of appd.AppSession'));
        end
        
        function context = get.Context(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            context = this.SessionManager.getSessionContext(this.SessionKey);
        end
        
        function set.Context(~, ~)
            throw(MException('AppSession:InvalidOperation', 'Can''t set Context property of appd.AppSession'));
        end
        
        function persister = get.PersistenceContainer(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            persister = this.Context;
        end
        
        function set.PersistenceContainer(this, persister)
            this.Context = persister;
        end
        
        function ioc = get.IocContainer(this)
            context = this.Context;
            ioc = context.IocContainer;
        end
        
        function set.IocContainer(this, ioc)
            context = this.Context;
            context.IocContainer = ioc;
        end
    end
    
    methods
        function this = AppSession(app, mgr, sessionKey)
            if ~mgr.validateSessionKey(sessionKey)
                mgr.raiseSessionExpiredError(sessionKey)
            end
            this.App = app;
            this.SessionManager = mgr;
            this.SessionKey = sessionKey;
            
            %**************************************************************
            %********* this is for refreshing the new timestamp ***********
            %**************************************************************
            c = this.Context;
            this.Status = appd.AppStatus.SessionLoaded;
        end
        
        function delete(this)
            this.clear();
        end
        
        function clear(this)
            % delete functionality
            this.SessionManager = appd.SessionManager.empty();
            this.App = appd.App.empty();
        end
        
        function start(this)
            % nothing to do here really
        end
        
        function restart(this)
            throw(MException('AppSession:InvalidOperation', 'Can''t restart session'));
        end
        
        function kill(this)
            delete(this);
        end
        
        function session = getSession(this, key)
            throw(MException('AppSession:InvalidOperation', 'Sessions can''t load sessions'));
        end
        
        function [key, session] = startSession(this)
            throw(MException('AppSession:InvalidOperation', 'Sessions can''t start new sessions'));
        end
        
        function clearAllSessions(this)
            throw(MException('AppSession:InvalidOperation', 'Can''t use session object to clear all sessions'));
        end
        
        function addKillItem(this, item)
            this.App.addKillItem(item);
        end
        
        function registerController(this, controller)
            this.App.registerController(controller);
        end
        
        function controller = getController(this, controllerName)
            controller = this.App.getController(controllerName);
            controller.App = this;
        end
        
        function clearSessionState(this)
            this.SessionManager.clearSession(this.SessionKey);
            this.delete();
        end
    end
    
    methods (Access=protected)
        
        function m = getMessenger(this)
            m = this.App.Messenger;
        end
    end
end

