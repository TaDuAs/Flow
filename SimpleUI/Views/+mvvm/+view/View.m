classdef (Abstract) View < mvvm.view.IView & matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    properties (Access=private)
        AppLoadingEventListener;
        
        % parent lifecycle event handlers
        OwnerViewEventHandlers event.listener;
    end
    
    properties (GetAccess=public,SetAccess=private)
        App mvvm.IApp = mvvm.App.empty();
        Status mvvm.view.ViewStatus = mvvm.view.ViewStatus.NotActivated;
    end
    
    properties
        OwnerView mvvm.view.IView = mvvm.view.Window.empty();
        Fig matlab.ui.Figure;
        Messenger mvvm.MessagingMediator;
        BindingManager mvvm.BindingManager;
        ModelProviderMapping mvvm.view.ViewProviderMapping;
        ViewManager mvvm.view.IViewManager = mvvm.view.ViewManager.empty();
        Id string;
    end
    
    methods
        function this = View(varargin)
            this.parseConfiguration(varargin);
            
            if ~isempty(this.App)
                this.registerToApp(this.App);
            end
            if ~isempty(this.ViewManager)
                this.ViewManager.register(this);
            end
            if ~isempty(this.OwnerView)
                % this will sign in to the owner views lifecycle events
                this.start();
            end
        end
        
        function deleta(this)
            if ~isempty(this.AppLoadingEventListener)
                delete(this.AppLoadingEventListener);
                this.AppLoadingEventListener = event.listener.empty();
            end
            if ~isempty(this.OwnerViewEventHandlers)
                delete(this.OwnerViewEventHandlers);
                this.OwnerViewEventHandlers = event.listener.empty();
            end
            
            this.App = mvvm.App.empty();
            this.BindingManager = mvvm.BindingManager.empty();
            this.ViewManager = mvvm.view.ViewManager.empty();
            this.OwnerView = mvvm.view.Window.empty();
            this.Fig = matlab.ui.Figure.empty();
            this.Messenger = mvvm.MessagingMediator.empty();
            this.ModelProviderMapping = mvvm.view.ViewProviderMapping.empty();
        end
        
        function start(this)
            if this.Status == mvvm.view.ViewStatus.NotActivated
                this.initiateLifecycle();
            end
        end
        
        function close(this)
            if ~isvalid(this)
                return;
            end
            this.onCloseRequest();
        end
        
        function show(this)
            set(this.getContainerHandle(), 'visible', 'on');
        end
        
        function hide(this)
            set(this.getContainerHandle(), 'visible', 'off');
        end
        
        % Deactivates view bindings
        function sleep(this)
            this.BindingManager.deactivateBindersDomain(this.getContainerHandle());
        end
        
        % Activates view bindings
        function wake(this)
            this.BindingManager.activateBindersDomain(this.getContainerHandle());
        end
    end
    
    methods (Access=protected)
        function init(this)
        end
        
        function initializeComponents(this)
        end
        
        function load(this)
        end
        
        function cancel = onClosing(this)
            cancel = false;
        end
        
        function handleCriticalError(this, err)
        end
        
        function parseConfiguration(this, args)
            % configure input parser
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
        
        function extractParserParameters(this, parser)
            this.App = parser.Results.App;
            
            % get messenger
            messenger = parser.Results.Messenger;
            if ~isempty(messenger)
                this.Messenger = messenger;
            elseif ~isempty(this.App) && ~isempty(this.App.Messenger)
                this.Messenger = this.App.Messenger;
            end
            
            % get binding manager
            bm = parser.Results.BindingManager;
            if ~isempty(bm)
                this.BindingManager = bm;
            elseif ~isempty(this.OwnerView)
                this.BindingManager = this.OwnerView.BindingManager;
            end
            
            % get data binding model provider
            if ~isempty(parser.Results.ModelProvider)
                this.ModelProviderMapping = mvvm.view.ViewProviderMapping(this.BindingManager, this, parser.Results.ModelProvider);
            end
            
            % get view manager and parent view
            this.ViewManager = parser.Results.ViewManager;
            if ~isempty(parser.Results.OwnerView)
                this.OwnerView = parser.Results.OwnerView;
%             elseif ~isempty(this.ViewManager)
%                 this.OwnerView = this.ViewManager.getOwnerView(this);
            end
            
            % get view id
            this.Id = parser.Results.Id;
        end
        
        function prepareParser(~, parser)
            % define parameters
            addParameter(parser, 'App', mvvm.App.empty(),...
                @(x) assert(isa(x, 'mvvm.IApp'), 'App must be mvvm.IApp or convertible type'));
            addParameter(parser, 'BindingManager', mvvm.GlobalBindingManager.instance(),...
                @(x) assert(isa(x, 'mvvm.BindingManager'), 'Binding manager must be a valid mvvm.BindingManager'));
            addParameter(parser, 'Messenger', mvvm.MessagingMediator.empty(), ...
                @(x) assert(isa(x, 'mvvm.MessagingMediator'), 'Messenger must be a mvvm.MessagingMediator or derived class'));
            addParameter(parser, 'ModelProvider', [], ...
                @(x) assert(isa(x, 'mvvm.providers.IModelProvider'), 'ModelProvider must be a mvvm.providers.IModelProvider'));
            addParameter(parser, 'ViewManager', mvvm.view.ViewManager.empty(), ...
                @(x) assert(isa(x, 'mvvm.view.IViewManager'), 'ViewManager must be a mvvm.view.ViewManager'));
            addParameter(parser, 'OwnerView', mvvm.view.Window.empty(), ...
                @(x) assert(isa(x, 'mvvm.view.IView'), 'OwnerView must be a mvvm.view.IView'));
            addParameter(parser, 'Id', guid(), @gen.valid.mustBeTextualScalar);
        end
        
        function onCloseRequest(this, ~, ~)
            try
                cancel = this.onClosing();

                % raise closing event and see if it is being cancelled
                cancelEvent = gen.CancelEventData();
                this.notify('closing', cancelEvent);
            catch ex
                warning(getReport(ex, 'extended', 'hyperlinks', 'on' ));
                this.handleCriticalError(ex);
                cancel = false;
                cancelEvent = gen.CancelEventData();
            end
            
            if ~cancel && ~cancelEvent.Cancel
                delete(this);
            end
        end
    end
    
    methods (Access=private)
        function initiateLifecycle(this)
            % get view owner
            owner = this.OwnerView;
            
            % get owner status
            if ~isempty(this.OwnerView)
                ownerStatus = owner.Status;
            else
                % when there is no owner, this views lifecycle should be
                % independent of anything.
                % simulate this by setting the owner status to the highest
                % status available
                ownerStatus = mvvm.view.ViewStatus.Closed;
            end
            
            %
            % ** automatically activate any events already fired by the
            % ** owner view
            %
            % initialize view
            if ownerStatus < mvvm.view.ViewStatus.Initialized
                this.OwnerViewEventHandlers(end + 1) = addlistener(owner, 'initialized', @this.onBeingInitialized);
            else
                this.onBeingInitialized();
            end

            % initialize view components
            if ownerStatus < mvvm.view.ViewStatus.ComponentsInitialized
                this.OwnerViewEventHandlers(end + 1) = addlistener(owner, 'componentsInitialized', @this.onComponentsBeingInitialized);
            else
                this.onComponentsBeingInitialized();
            end

            % load view
            if ownerStatus < mvvm.view.ViewStatus.Loaded
                this.OwnerViewEventHandlers(end + 1) = addlistener(owner, 'loaded', @this.onBeingLoaded);
            else
                this.onBeingLoaded();
            end
        end
        
        function onBeingInitialized(this, ~, ~)
            % perform view initialization
            this.init();

            % fire initialization lifecycle event
            this.Status = mvvm.view.ViewStatus.Initialized;
            notify(this, 'initialized');
        end
        
        function onComponentsBeingInitialized(this, ~, ~)
            % perform component initialization
            this.initializeComponents();

            % fire component initialization lifecycle event
            this.Status = mvvm.view.ViewStatus.ComponentsInitialized;
            notify(this, 'componentsInitialized');
        end
        
        function onBeingLoaded(this, ~, ~)
            % perform view load
            this.load();

            % fire loading lifecycle event
            this.Status = mvvm.view.ViewStatus.Loaded;
            notify(this, 'loaded');
            
            delete(this.OwnerViewEventHandlers)
            this.OwnerViewEventHandlers = event.listener.empty();
        end
        
        function registerToApp(this, app)
            if app.Status >= mvvm.AppStatus.Loaded
                this.start();
            else
                this.AppLoadingEventListener = app.addlistener('loading', @this.onAppLoading);
            end
        end
        
        function onAppLoading(this, app, eData)
            this.start();
            delete(this.AppLoadingEventListener);
            this.AppLoadingEventListener = [];
        end
    end
end

