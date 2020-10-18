classdef AppSession < mvvm.IApp
    % App class decorator.
    % Implement a session persistence on the Application by overriding the
    % Context property, and returning a session-key based instance
    % To access application-context PersistenceContainer access
    % mvvm.App.Context
    % directly.
    
    properties
        SessionKey = [];
    end
    
    properties (Access=private)
        App mvvm.IApp = mvvm.App.empty();
        SessionManager mvvm.SessionManager;
    end
    
    properties (Hidden, Dependent)
        PersistenceContainer;
    end
    
    properties (GetAccess=public, SetAccess=protected)
        % Application status
        Status mvvm.AppStatus = mvvm.AppStatus.NotAvailable;
    end
    
    properties (GetAccess=public, SetAccess=private, Dependent)
        % Dependency injection container
        IocContainer IoC.IContainer = IoC.Container.empty();
        
        % Application context object - for application-wide state management
        Context mvvm.AppContext;
        
        % Application-wide mediator class
        Messenger mvvm.MessagingMediator;
    end
    
    methods % allow property access for wrapped app props
        function varargout = subsref(A, S)
            varargout = cell(1, nargout);
            
            if strcmp(S(1).type, '.')
                subsStr = string(S(1).subs);
                firstSubs = subsStr(1);
                if all(ismethod(A, firstSubs))
                    if nargout < 1
                        mc = metaclass(A);
                        currMethod = mc.MethodList(strcmp(firstSubs, {mc.MethodList.Name}));
                        varargout = cell(1, min(1, numel(currMethod.OutputNames)));
                    end
                    
                    [varargout{:}] = builtin('subsref', A, S);
                elseif all(~isprop(A, firstSubs)) && all(isprop([A.App], firstSubs))
                    [varargout{:}] = subsref([A.App], S);
                else
                    [varargout{:}] = builtin('subsref', A, S);
                end
            else
                [varargout{:}] = builtin('subsref', A, S);
            end
        end
        
        function A = subsasgn(A,S,B)
            if strcmp(S(1).type, '.')
                subsStr = string(S(1).subs);
                firstSubs = subsStr(1);
                if all(~isprop(A, firstSubs)) && all(ismethod(A, firstSubs)) && all(isprop([A.App], firstSubs))
                    A = subsasgn([A.App], S, B);
                else
                    A = builtin('subsasgn', A, S, B);
                end
            else
                A = builtin('subsasgn', A, S, B);
            end
        end
    end
    
    methods % Property accessors
        function app = getApp(this)
            app = this.App;
        end
        
        function m = get.Messenger(this)
            m = this.App.Messenger;
        end
        function set.Messenger(~, ~)
            throw(MException('AppSession:InvalidOperation', 'Can''t set Messenger property of mvvm.AppSession'));
        end
        
        function context = get.Context(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            context = this.SessionManager.getSessionContext(this.SessionKey);
        end
        
        function set.Context(~, ~)
            throw(MException('AppSession:InvalidOperation', 'Can''t set Context property of mvvm.AppSession'));
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
            this.Status = mvvm.AppStatus.SessionLoaded;
        end
        
        function delete(this)
            this.clear();
        end
        
        function clear(this)
            % delete functionality
            this.SessionManager = mvvm.SessionManager.empty();
            this.App = mvvm.App.empty();
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
        % Gets the controlle in current session context
            controller = this.buildController(controllerName);
            controller.init(this);
            
            % Bug fix - don't use this.App.buildController 
            % When letting the app build the controller, if using an
            % mvvm.IoCControllerBuilder, it will build it with the main App
            % IoC.Container - thus using the wrong context for controlle
            % manufacturing.
            % 
            % Instead copy the controller builder locally and apply the
            % current session IoC.Container.
            % 
            % This was pretty vicious to debug...
        end
        
        function clearSessionState(this)
            this.SessionManager.clearSession(this.SessionKey);
            this.delete();
        end
        
        function handleException(this, varargin)
            this.App.handleException(varargin{:});
        end
    end
    
    methods (Access=protected)
        function controller = buildController(this, controllerName)
            controllerBuilder = this.getControllerBuilder(controllerName);
            controller = controllerBuilder.build();
            
            if isempty(controller) || ~isa(controller, 'mvvm.AppController')
                throw(MException('App:GetController:InvalidController', ['Controller ' char(controllerName) ' invalid']));
            end
        end
        
        function m = getMessenger(this)
            m = this.App.Messenger;
        end
    end
    
    % internal methods
    methods (Access={?mvvm.App, ?mvvm.AppSession})
        % get a controller builder by name
        function localBuilder = getControllerBuilder(this, controllerName)
            originalBuilder = this.App.getControllerBuilder(controllerName);
            localBuilder = originalBuilder.copy(this);
        end
    end
end

