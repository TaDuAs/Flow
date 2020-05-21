classdef App < handle
    % App handles application persistence
    % Functionality includes:
    %   singleton instance
    %   application load status
    %   loading of derived application classes for extended functionality
    %   persistence object map PersistenceContainer
    %   class factory, loading of custom factory initializers
    %   controllers
    %   Logger
    %
    
    properties (Constant)
        % for backwards compatibility
        ApplicationStatus = Simple.enum2struct('Simple.App.ApplicationStatus');
    end
    
    properties (Access=private)
        controllerBuilders = [];
        persistenceContainerInstance Simple.App.PersistenceContainer;
        killList = {};
        messenger_ Simple.App.MessagingMediator;
    end
    
    properties (Access=protected)
        classFactoryBuilder = [];
    end
        
    properties (GetAccess=public,SetAccess=private)
        statusType (1,1) Simple.App.ApplicationStatus = Simple.App.ApplicationStatus.notAvailable;
    end
    
    properties (GetAccess=public, SetAccess=private, Dependent)
        iocContainer IoC.IContainer = IoC.Container.empty();
        persistenceContainer Simple.App.PersistenceContainer;
        messenger Simple.App.MessagingMediator;
    end
    
    methods % Property accessors
        function app = getApp(this)
            app = this;
        end
        
        function m = get.messenger(this)
            m = this.getMessenger();
        end
        function set.messenger(this, m)
            this.setMessenger(m);
        end
        
        function persister = get.persistenceContainer(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            persister = this.persistenceContainer_getter();
        end
        
        function set.persistenceContainer(~, ~)
            error('Don''t set this property, set persistenceContainerInstance instead');
        end
        
        function ioc = get.iocContainer(this)
            % iocContainer property getter function - allows overriding in
            % derived classes
            ioc = this.iocContainer_getter();
        end
        
        function set.iocContainer(this, ioc)
            % iocContainer property setter function - allows overriding in
            % derived classes
            this.iocContainer_setter(ioc);
        end
    end
    
    methods (Access=protected) % Overridable property accessors
        function persister = persistenceContainer_getter(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            persister = this.persistenceContainerInstance;
        end
        
        function ioc = iocContainer_getter(this)
            persister = this.persistenceContainer;
            ioc = persister.iocContainer;
        end
        function iocContainer_setter(this, ioc)
            persister = this.persistenceContainer;
            persister.iocContainer = ioc;
        end
        
        function m = getMessenger(this)
            m = this.messenger_;
        end
        function setMessenger(this, m)
            this.messenger_ = m;
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
            
            this.statusType = Simple.App.ApplicationStatus.configuring;
            
            % load app configuration - IoC and stuff
            this.initConfig();
            
            this.statusType = Simple.App.ApplicationStatus.initializing;
            
            % initialize
            this.init();
            
            this.statusType = Simple.App.ApplicationStatus.startup;
            
            % load application
            this.load();
            
            this.statusType = Simple.App.ApplicationStatus.loaded;
        end
        
        function restart(this)
            this.clear();
            this.initiateLifeCycle();
        end
        
        function initConfig(this)
            this.iocContainer.set('App', @Simple.App.App.current);
            this.iocContainer.setSingleton('Messenger', @(app) app.messenger, 'App');
            
            if ~isempty(this.classFactoryBuilder)
                Simple.IO.MXML.Factory.init(this.classFactoryBuilder);
            end
        end
        
        function init(this)
        end
        
        function load(this)
        end
        
    end
    
    methods (Access=protected) % ctor dtor
        function this = App(ioc, varargin)
            Simple.obsoleteWarning('Simple.App');
            import Simple.App.*;
            
            if nargin < 2 || isempty(ioc)
                ioc = IoC.Container();
            end
            
            % Instantiate app PersistenceContainer & class factory
            this.persistenceContainerInstance = PersistenceContainer(ioc);
            
            if nargin >= 2 && isobject(varargin{1})
                classFactoryBuilder = varargin{1};
                args = varargin(2:end);
            else
                classFactoryBuilder = Simple.App.ClassFactoryBuilder.empty();
                args = varargin;
            end
            
            this.parseConfig(args);
            
            % Instantiate class factory builder
            if ~isempty(classFactoryBuilder)
                this.classFactoryBuilder = classFactoryBuilder;
            end
            
            this.messenger = Simple.App.MessagingMediator(this);
        end
        
        function clear(this)
            this.statusType = Simple.App.ApplicationStatus.terminated;
            this.persistenceContainer.clearCache();
            
            warnstate = warning('query', 'MXML:Factory:Obsolete');
            warning('off', 'MXML:Factory:Obsolete');
            Simple.IO.MXML.Factory.terminate();
            warning(warnstate.state, 'MXML:Factory:Obsolete')
            this.controllerBuilders = [];
            
            Simple.App.AppSession.clearSessionContainer();
            cellfun(@delete, this.killList);
            this.killList = {};
        end
        
        function kill(this)
            this.delete();
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
        end
        
        function extractParserParameters(this, parser)
        end
    end
    
    methods
        function delete(this)
            this.clear();
        end
        
        function session = getSession(this, key)
            session = Simple.App.AppSession(this, key);
        end
        
        function [key, session] = startSession(this)
            key = Simple.App.AppSession.startNewSession();
            
            if nargout >= 2
                session = this.getSession(key);
            end
        end
        
        function addKillItem(this, item)
            this.killList{numel(this.killList) + 1} = item;
        end
        
        function registerController(this, controller)
            % Register an AppController
            if isa(controller, 'Simple.App.AppControllerBuilder')
                this.controllerBuilders.(controller.controllerName) = controller;
            else
                throw(MException('App:RegisterController:InvalidControllerRegistration', 'Registered controller must be a valid Simple.App.AppControllerBuilder'));
            end
        end
        
        function controller = getController(this, controllerName)
            if isfield(this.controllerBuilders, controllerName)
                controller = this.controllerBuilders.(controllerName).build();
                controller.app = this;
            else
                throw(MException('App:GetController:NotRegistered', ['Controller ' controllerName ' not registered']));
            end
            
            if isempty(controller) || ~isa(controller, 'Simple.App.AppController')
                throw(MException('App:GetController:InvalidController', ['Controller ' controllerName ' invalid']));
            end
        end
    end
    
    methods (Static, Access=private)
        function logError(msg, err, path, fileName)
            if isa(err, 'MException')
                err = getReport(err, 'extended');
            end
            logger = Simple.App.App.logger(path, fileName);
            logger.error('', [msg sprintf('\n') err]);
        end
        
        function app = instance(app, shouldInstantiate, shouldTerminate)
            if nargin < 2
                shouldInstantiate = true;
            end
            if nargin < 3
                shouldTerminate = false;
            end
            
            persistent appInstance;
            
            if shouldTerminate
                if ~isempty(appInstance) && isvalid(appInstance)
                    appInstance.kill();
                end
                appInstance = Simple.App.App.empty();
            else
                if nargin >= 1 && isa(app, 'Simple.App.App')
                    appInstance = app;
                else
                    if (~isempty(appInstance) && isa(appInstance, 'handle') && ~isvalid(appInstance)) || (isempty(appInstance) && shouldInstantiate)
                        appInstance = Simple.App.App();
                    end
                    app = appInstance;
                end
            end
        end
        
        function bool = hasInstance()
            bool = ~isempty(Simple.App.App.instance([], false));
        end
    end
    
    methods (Static)
        function app = current()
            app = Simple.App.App.instance;
        end
        
        % was a weird dream at some point
%         function startInWorkerProcess(app)
%             Simple.App.App.start(app.getRegisteredAppForWorkerProcess())
%         end
        
        function start(app)
            if nargin < 1 || ~isa(app, 'Simple.App.App')
                throw(MException('App:Start:InvalidApp', 'Must load a valid Simple.App.App object'));
            end
            Simple.App.App.instance(app);
            
            app.initiateLifeCycle();
        end
        
        function persister = getPersistenceContainer()
            persister = Simple.App.App.instance().persistenceContainer;
        end
        
        function terminate()
            Simple.App.App.instance([], false, true);
        end
        
        function reset()
            Simple.App.App.instance.restart();
        end
        
        function type = status()
            type = Simple.App.App.instance.statusType;
        end
        
        function bool = isReady()
            if ~Simple.App.App.hasInstance()
                bool = false;
                return;
            end
            
            bool = Simple.App.App.instance.statusType == Simple.App.ApplicationStatus.loaded;
        end
        
        function key = startNewSession()
            app = Simple.App.App.instance();
            key = app.startSession();
        end
        
        function session = loadSession(key)
            app = Simple.App.App.instance();
            session = app.getSession(key);
        end
        
        function handleException(a, b, path, fileName)
            % handleException(msg, exception, [path, fileName]) - logs the
            % exception and the message. If specified, logs into the
            % specified path and file name
            %
            % handleException(exception)
            if nargin < 4
                fileName = [];
            end
            if nargin < 3
                path = [];
            end
            if ~isa(a, 'MException')
                Simple.App.App.logError(a, b, path, fileName);
            else
                Simple.App.App.logError('', a, path, fileName);
            end
        end
        
        function log = logger(path, fileName)
            [path1, fileName1] = Simple.App.App.instance.getLogPath();
            
            if nargin < 1 || isempty(path)
                path = path1;
            end
            if nargin < 2 || isempty(fileName)
                fileName = fileName1;
            end
            
            if ~exist(path, 'dir')
                mkdir(path);
            end
            
            fullLogPath = fullfile(path, fileName);
            
            log = log4m.getLogger(fullLogPath);
            
            if ~strcmp(log.fullpath, fullLogPath)
                log = log4m.forceNewLogger(fullLogPath);
            end
        end
    end
    
end

