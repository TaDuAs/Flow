classdef App < mvvm.IApp
    % App handles application persistence
    % Functionality includes:
    %   IoC.Container - Dependency injection
    %   Application Context - for application wide caching
    %   Sessions Management - for per-session caching, also interacts with
    %                         the IoC.Container session
    %   App-Domain Messaging Mediator - Cross layer application event handling
    %   App-Controllers - manage App controllers for MVC/MVVM/services
    %   Logger - Everyone knows who you are
    %   Kill List - List of keep-alive objects to destroy upon termination
    %               of the app
    %   
    
    events
        configuring;
        initializing;
        loading;
    end
    
    properties (Access=private)
        ControllerBuilders = [];
        Context_ mvvm.AppContext;
        KillList = {};
        Messenger_ mvvm.MessagingMediator;
        SessionManager mvvm.SessionManager;
    end
    
    properties (GetAccess=public, SetAccess=protected)
        Id string;
        Status mvvm.AppStatus = mvvm.AppStatus.NotAvailable;
        LogPath char;
        Logger logs.ILogger = logs.Log4Wrapper.empty();
    end
    
    properties (GetAccess=public, SetAccess=private, Dependent)
        IocContainer IoC.IContainer;
        Context mvvm.AppContext;
        Messenger mvvm.MessagingMediator;
    end
    
    properties (Hidden, GetAccess=public, SetAccess=private, Dependent)
        PersistenceContainer mvvm.AppContext;
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
            path = this.LogPath;
            filename = ['error_' datestr(now, 'yyyy-mm-dd') '.log'];% ['error ' datestr(now, 'yyyy-mm-dd.HH.MM.SS.FFF') '.log'];
        end
    end
    
    methods (Access=protected) % lifecycle methods
        
        % lifecycle
        function initiateLifeCycle(this)
            % Starts application lifecycle events in order
            
            this.Status = mvvm.AppStatus.Configuring;
            
            % load app configuration - IoC and stuff
            this.initConfig();
            
            this.Status = mvvm.AppStatus.Initializing;
            
            % initialize
            this.init();
            
            this.Status = mvvm.AppStatus.Startup;
            
            % load application
            this.load();
            
            this.Status = mvvm.AppStatus.Loaded;
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
            addParameter(parser, 'LogPath', pwd, @gen.valid.mustBeTextualScalar);
            addParameter(parser, 'Logger', logs.Log4Wrapper.empty(), @(l) assert(isa(l, 'logs.ILogger'), 'Invalid data type. Value must be logs.ILogger or be convertible to logs.ILogger.'));
        end
        
        function extractParserParameters(this, parser)
            this.Id = string(parser.Results.Id);
            this.LogPath = string(parser.Results.LogPath);
            
            if isempty(parser.Results.Logger)
                this.Logger = logs.Log4Wrapper(this.LogPath);
            else
                this.Logger = parser.Results.Logger;
            end
        end
        
        function log = getLogger(this, path, fileName)
            [path1, fileName1] = this.getLogPath();
            
            if nargin < 2 || isempty(path)
                path = path1;
            end
            if nargin < 3 || isempty(fileName)
                fileName = fileName1;
            end
            
            if ~exist(path, 'dir')
                mkdir(path);
            end
            
            fullLogPath = fullfile(path, fileName);
            
            log = this.Logger;
            if ~strcmp(log.getFilename(), fullLogPath)
                log.setFilename(fullLogPath);
            end 
        end
    end
    
    methods % ctor dtor
        function this = App(ioc, varargin)
            if nargin < 1 || isempty(ioc)
                ioc = IoC.Container('MainApplication.IoC');
            end
            
            % Instantiate app PersistenceContainer & class factory
            this.Context_ = mvvm.AppContext(ioc);
            
            this.parseConfig(varargin);
            
            this.Messenger_ = mvvm.MessagingMediator(this);
            this.SessionManager = mvvm.SessionManager(this);
        end
        
        function clear(this)
            if this.Status == mvvm.AppStatus.Terminated
                return;
            end
            this.Status = mvvm.AppStatus.Terminated;
            this.Context.clearCache();
            
            this.ControllerBuilders = [];
            
            if ~isempty(this.SessionManager)
                this.SessionManager.clearSessionContainer();
            end 
            cellfun(@delete, this.KillList);
            this.KillList = {};
        end
        
        function start(this)
            % For a running app don't do anything
            if this.Status == mvvm.AppStatus.NotAvailable
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
            
            if ~isempty(this.IocContainer) && isvalid(this.IocContainer)
                this.IocContainer.delete();
                this.IocContainer = IoC.Container.empty();
            end
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
            if isa(controller, 'mvvm.AppControllerBuilder')
                this.ControllerBuilders.(controller.ControllerName) = controller;
            else
                throw(MException('App:RegisterController:InvalidControllerRegistration', 'Registered controller must be a valid mvvm.AppControllerBuilder'));
            end
        end
        
        function controller = getController(this, controllerName)
            controller = this.buildController(controllerName);
            controller.init(this);
        end
        
        function handleException(this, err, msg)
            % handleException(exception, message) - logs the
            % exception and the message. If specified, logs into the
            % specified path and file name
            %
            % handleException(exception)
            if isa(err, 'MException')
                err = getReport(err, 'extended');
            end
            if nargin >= 3
                logText = [msg, newline, err];
            else
                logText = err;
            end
            
            logger = this.getLogger();
            logger.error('', logText);
        end
    end
    
    methods (Access={?mvvm.App, ?mvvm.AppSession})
        function controllerBuilder = getControllerBuilder(this, controllerName)
            if isfield(this.ControllerBuilders, controllerName)
                controllerBuilder = this.ControllerBuilders.(controllerName);
            else
                throw(MException('App:GetController:NotRegistered', ['Controller ' char(controllerName) ' not registered']));
            end
        end
    end
    
    methods (Access=private)
        function controller = buildController(this, controllerName)
            controllerBuilder = this.getControllerBuilder(controllerName);
            controller = controllerBuilder.build();
            
            if isempty(controller) || ~isa(controller, 'mvvm.AppController')
                throw(MException('App:GetController:InvalidController', ['Controller ' char(controllerName) ' invalid']));
            end
        end
    end
end

