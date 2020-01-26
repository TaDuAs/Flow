classdef App < appd.IApp
    % App handles application persistence
    % Functionality includes:
    %   singleton instance
    %   application load status
    %   loading of derived application classes for extended functionality
    %   cache object
    %   class factory, loading of custom factory initializers
    %   controllers
    %   Logger
    %
    
    events
        configuring;
        initializing;
        loading;
    end
    
    properties (Access=private)
        ControllerBuilders = [];
        Context_ appd.AppContext;
        KillList = {};
        Messenger_ appd.MessagingMediator;
        SessionManager appd.SessionManager;
    end
    
    properties (GetAccess=public, SetAccess=protected)
        Id string;
        Status appd.AppStatus = appd.AppStatus.NotAvailable;
    end
    
    properties (GetAccess=public, SetAccess=private, Dependent)
        IocContainer IoC.IContainer;
        Context appd.AppContext;
        Messenger appd.MessagingMediator;
    end
    
    properties (Hidden, GetAccess=public, SetAccess=private, Dependent)
        PersistenceContainer appd.AppContext;
    end
    
    methods % Property accessors
        function app = getApp(this)
            app = this;
        end
        
        function m = get.Messenger(this)
            m = this.getMessenger();
        end
        function set.Messenger(this, m)
            this.setMessenger(m);
        end
        
        function context = get.Context(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            context = this.context_getter();
        end
        
        function set.Context(~, ~)
            error('Don''t set this property, set Context_ instead');
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
            % iocContainer property getter function - allows overriding in
            % derived classes
            ioc = this.iocContainer_getter();
        end
        
        function set.IocContainer(this, ioc)
            % iocContainer property setter function - allows overriding in
            % derived classes
            this.iocContainer_setter(ioc);
        end
    end
    
    methods (Access=protected) % Overridable property accessors
        function context = context_getter(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            context = this.Context_;
        end
        
        function ioc = iocContainer_getter(this)
            context = this.Context_;
            ioc = context.IocContainer;
        end
        function iocContainer_setter(this, ioc)
            context = this.Context_;
            context.IocContainer = ioc;
        end
        
        function m = getMessenger(this)
            m = this.Messenger_;
        end
        function setMessenger(this, m)
            this.Messenger_ = m;
        end
        
        function [path, filename] = getLogPath(this)
            path  = pwd;
            filename = ['error ' datestr(now, 'yyyy-mm-dd.HH.MM.SS.FFF') '.log'];
        end
    end
    
    methods (Access=protected) % lifecycle methods
        
        % lifecycle
        function initiateLifeCycle(this)
            % Starts application lifecycle events in order
            
            this.Status = appd.AppStatus.Configuring;
            
            % load app configuration - IoC and stuff
            this.initConfig();
            
            this.Status = appd.AppStatus.Initializing;
            
            % initialize
            this.init();
            
            this.Status = appd.AppStatus.Startup;
            
            % load application
            this.load();
            
            this.Status = appd.AppStatus.Loaded;
        end
        
        function initConfig(this)
            notify(this, 'configuring');
            
            this.IocContainer.set('App', @() this);
            this.IocContainer.setSingleton('Messenger', @(app) app.Messenger, 'App');
        end
        
        function init(this)
            notify(this, 'initializing');
        end
        
        function load(this)
            notify(this, 'loading');
        end
        
        function parseConfig(this, args)
            parser = inputParser();
            parser.CaseSensitive = false;
            parser.FunctionName = class(this);
            
            % add all parameters to the parser
            this.prepareParser(parser);
            
            % parse input
            parse(parser, args{:});
            
            % extract all parsed parameters
            this.extractParserParameters(parser);
        end
        
        function prepareParser(this, parser)
            addParameter(parser, 'Id', class(this), @gen.valid.mustBeTextualScalar);
        end
        
        function extractParserParameters(this, parser)
            this.Id = string(parser.Results.Id);
        end
    end
    
    methods % ctor dtor
        function this = App(ioc, varargin)
            if nargin < 1 || isempty(ioc)
                ioc = IoC.Container();
            end
            
            % Instantiate app PersistenceContainer & class factory
            this.Context_ = appd.AppContext(ioc);
            
            this.parseConfig(varargin);
            
            this.Messenger_ = appd.MessagingMediator(this);
            this.SessionManager = appd.SessionManager(this);
        end
        
        function clear(this)
            if this.Status == appd.AppStatus.Terminated
                return;
            end
            this.Status = appd.AppStatus.Terminated;
            this.Context.clearCache();
            
            this.ControllerBuilders = [];
            
            this.SessionManager.clearSessionContainer();
            cellfun(@delete, this.KillList);
            this.KillList = {};
        end
        
        function start(this)
            % For a running app don't do anything
            if this.Status == appd.AppStatus.NotAvailable
                this.initiateLifeCycle();
            end
        end
        
        function restart(this)
            this.clear();
            this.start();
        end
        
        function kill(this)
            this.delete();
        end
        
        function delete(this)
            this.clear();
        end
    end
    
    methods % session/controller handling
        function session = getSession(this, key)
            session = this.SessionManager.getSession(key);
        end
        
        function [key, session] = startSession(this)
            [key, session] = this.SessionManager.startNewSession();
        end
        
        function clearAllSessions(this)
            this.SessionManager.clearSessionContainer();
        end
        
        function addKillItem(this, item)
            this.KillList{numel(this.KillList) + 1} = item;
        end
        
        function registerController(this, controller)
            % Register an AppController
            if isa(controller, 'appd.AppControllerBuilder')
                this.ControllerBuilders.(controller.ControllerName) = controller;
            else
                throw(MException('App:RegisterController:InvalidControllerRegistration', 'Registered controller must be a valid appd.AppControllerBuilder'));
            end
        end
        
        function controller = getController(this, controllerName)
            if isfield(this.ControllerBuilders, controllerName)
                controller = this.ControllerBuilders.(controllerName).build();
                controller.App = this;
            else
                throw(MException('App:GetController:NotRegistered', ['Controller ' char(controllerName) ' not registered']));
            end
            
            if isempty(controller) || ~isa(controller, 'appd.AppController')
                throw(MException('App:GetController:InvalidController', ['Controller ' char(controllerName) ' invalid']));
            end
        end
    end
end

