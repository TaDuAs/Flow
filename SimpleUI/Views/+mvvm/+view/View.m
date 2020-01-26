classdef (Abstract) View < mvvm.view.IView & matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    properties (Access=private)
        AppLoadingEventListener;
    end
    
    properties (GetAccess=public,SetAccess=private)
        App appd.IApp = appd.App.empty();
        Status (1,1) mvvm.view.ViewStatus = mvvm.view.ViewStatus.NotActivated;
    end
    
    properties
        OwnerView mvvm.view.IView = mvvm.view.Window.empty();
        Fig matlab.ui.Figure;
        Messenger appd.MessagingMediator;
        BindingManager mvvm.BindingManager;
        ModelProviderMapping mvvm.view.ViewProviderMapping;
        ViewManager mvvm.view.IViewManager = mvvm.view.ViewManager.empty();
    end
    
    methods
        function this = View(varargin)
            this.parseConfiguration(varargin);
            
            if ~isempty(this.App)
                this.registerToApp(this.App);
            end
        end
        
        function start(this)
            if this.Status == mvvm.view.ViewStatus.NotActivated
                this.initiateLifecycle();
            end
        end
        
        function close(this)
            this.onCloseRequest();
        end
        
        function ownerView = getOwnerView(this)
            if ~isempty(this.OwnerView)
                ownerView = this.OwnerView;
            elseif ~isempty(this.ViewManager)
%                 ownerView = this.ViewManager.get();
            end
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
            
            % first of all, get binding manager
            this.BindingManager = parser.Results.BindingManager;
            
            % get control event name
            this.Messenger = parser.Results.Messenger;
            
            if ~isempty(parser.Results.ModelProvider)
                this.ModelProviderMapping = mvvm.view.ViewProviderMapping(this.BindingManager, this, parser.Results.ModelProvider);
            end
            
            this.ViewManager = parser.Results.ViewManager;
        end
        
        function prepareParser(~, parser)
            % define parameters
            addParameter(parser, 'App', appd.App.empty(),...
                @(x) assert(isa(x, 'appd.App'), 'App must be appd.App or convertible type'));
            addParameter(parser, 'BindingManager', mvvm.BindingManager.instance(),...
                @(x) assert(isa(x, 'mvvm.BindingManager'), 'Binding manager must be a valid mvvm.BindingManager'));
            addParameter(parser, 'Messenger', appd.MessagingMediator.empty(), ...
                @(x) assert(isa(x, 'appd.MessagingMediator'), 'Messenger must be a appd.MessagingMediator or derived class'));
            addParameter(parser, 'ModelProvider', [], ...
                @(x) assert(isa(x, 'mvvm.providers.IModelProvider'), 'ModelProvider must be a mvvm.providers.IModelProvider'));
            addParameter(parser, 'ViewManager', mvvm.view.ViewManager.empty(), ...
                @(x) assert(isa(x, 'mvvm.view.ViewManager'), 'ViewManager must be a mvvm.view.ViewManager'));
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
            this.init();
            
            this.Status = mvvm.view.ViewStatus.Initialized;
            notify(this, 'initialized');
            
            this.initializeComponents();
            
            this.Status = mvvm.view.ViewStatus.ComponentsInitialized;
            notify(this, 'componentsInitialized');
            
            this.load();
            
            this.Status = mvvm.view.ViewStatus.Loaded;
            notify(this, 'loaded');
        end
        
        function registerToApp(this, app)
            if app.Status >= appd.AppStatus.Loaded
                this.start();
            else
                this.AppLoadingEventListener = app.addlistener('loading', @this.onAppLoading);
            end
        end
        
        function onAppLoading(this, app, eData)
            this.start();
        end
    end
end

