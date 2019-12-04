classdef Binder < mvvm.ModelPathObserver & mvvm.ControlObserver & mvvm.IBinderBase
    % A generic 2-way data binder for matlab GUIs. mvvm.Binder works the 
    % same with classic Matlab UI components and the new Web-Based UI
    % components (AppDesigner)
    %
    % binder = mvvm.Binder(modelPath, control, property)
    %   summary: constructs a 1-way data binder which binds the data in the
    %   specified model path to a property of a given control.
    %   input:
    %       modelPath - the field/property path to observe in the model
    %       control - a Matlab UI component
    %       property - the property of control to bind the model value to
    %
    % binder = mvvm.Binder(___, name, value)
    %   summary: constructs a binder with extra parametsrs
    % 
    %----------------------------------------------------------------------
    % Name-Value pair arguments:
    %----------------------------------------------------------------------
    % BindingManager: allows dependency injection of a mvvm.BindingManager
    % instance (or custom implementation or mocked instance for testing
    % purposes)
    %
    % Event: The event name to observe in the control. Use this parameter
    % to construct a 2-way data binder which observes changes in the
    % control and automatically updates the model
    %
    % ModelProvider: allows dependency injection of a mvvm.providers.IModelProvider
    % instance. Provides access to the model object, must implement 
    % mvvm.providers.IModelProvider. If not specified, this mvvm.Binder 
    % uses the model provider registered in the BindingManager for the
    % figure which contains the control.
    %
    % UpdateDelay: Delays updating the model when the control's event is
    % raised. Use delay when you want to prevent the binder from updating
    % the model every time the control is updated on rapid user events such
    % as keyboard key strokes
    % example:
    %   % configure model
    %   model = struct();
    %   model.config.smoothing.method = 'moving';
    %   model.config.smoothing.span = '10';
    %   modelProvider = mvvm.providers.AppDataModelProvider(gcf, 'model');
    %   modelProvider.setModel(model);
    %   mvvm.BindingManager.setModProv(gcf, modelProvider);
    %
    %   % set up gui
    %   textedit = uicontrol(gcf, 'style', 'edit');
    %
    %   % set up 2-way binding
    %   binder = mvvm.Binder('config.smoothing.span', ...
    %       textedit,...
    %       'String',...
    %       'Event', 'KeyRelease',...
    %       'UpdateDelay', 0.2);
    
    properties (Access=protected)
        % This is a handle to a timer which will execute model update after
        % the control event fires and a certain timeout fires
        ModelUpdateTimer;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        BindingManager;
        ControlProperty;
        ModelUpdateDelay;
        ModelIndexer mvvm.providers.IModelIndexer;
    end
    
    methods
        
        function this = Binder(modelPath, control, property, varargin)
        % Constructs a data binder object and starts listening to
        % changes    
            % call base ctor
            this@mvvm.ModelPathObserver();
            this@mvvm.ControlObserver();
            
            % parse modular input using varargin
            this.parseConfiguration(control, varargin);
            
            % initialize binder
            this.init(modelPath, control, property);
        end
        
        function delete(this)
            if ~isvalid(this)
                return;
            end
            
            % delete this
            delete@mvvm.ModelPathObserver(this);
            delete@mvvm.ControlObserver(this);
            
            % delete update timer
            if ~isempty(this.ModelUpdateTimer)
                delete(this.ModelUpdateTimer);
                this.ModelUpdateTimer = [];
            end
            
            % decouple from binding manager
            if ~isempty(this.BindingManager) && isvalid(this.BindingManager)
                this.BindingManager.clearBinder(this);
                this.BindingManager = [];
            end
        end
        
        function start(this, what)
            if nargin < 2 || isempty(what); what = 'all'; end
            
            if any(strcmp(what, {'all', 'model'}))
                start@mvvm.ModelPathObserver(this);
            end
            if any(strcmp(what, {'all', 'control'}))
                start@mvvm.ControlObserver(this);
            end
        end
        
        function stop(this, what)
            if nargin < 2 || isempty(what); what = 'all'; end
            
            if any(strcmp(what, {'all', 'model'}))
                stop@mvvm.ModelPathObserver(this);
            end
            if any(strcmp(what, {'all', 'control'}))
                stop@mvvm.ControlObserver(this);
            end
        end
    end
    
    methods (Access=protected)
        function init(this, modelPath, control, property)
            init@mvvm.ModelPathObserver(this, modelPath, this.ModelProvider);
            init@mvvm.ControlObserver(this, control);
            
            % configure binder-control interaction
            this.Control = control;
            this.ControlProperty = property;
            this.setupControlBinding();
            
            % initial model 2 control binding
            this.bindData(this.ModelProvider.getModel(), this.ModelPath);
            
            % keep binder alive
            this.BindingManager.saveBinder(this);
        end
        
        function setupControlBinding(this)
            % configure binder delay on conrtol event being raise.
            if this.ModelUpdateDelay > 0
                this.ModelUpdateTimer = timer();
                this.ModelUpdateTimer.TimerFcn = @this.executeControlUpdate;
                this.ModelUpdateTimer.TasksToExecute = 1;
                this.ModelUpdateTimer.StartDelay = this.ModelUpdateDelay;
            end
            
            % Listen to control events
            setupControlBinding@mvvm.ControlObserver(this);
        end
        
        function handleControlUpdate(this, arg)
            this.stop('model');
            
            % execute a workaround for some strange behaviours for some
            % Matlab events
            this.workaroundMatlabStrangeBugs(arg);

            if this.ModelUpdateDelay > 0
                % stop previous timer, and delay the model-update operation
                % again
                stop(this.ModelUpdateTimer);
                
                % start delayed model update operation
                start(this.ModelUpdateTimer);
            else
                this.executeControlUpdate();
            end
        end
        
        function executeControlUpdate(this, ~, ~)
        % updates the model on control update event
            value = this.extractValueFromControl();
            scope = this.ModelProvider.getModel();
            [rescope, didLocateHandle] = mvvm.setobj(scope, this.ModelPath, value, this.ModelIndexer);
            if ~didLocateHandle
                this.ModelProvider.setModel(rescope);
            end
            
            this.start('model');
        end
        
        function value = extractValueFromControl(this)
            value = get(this.Control, this.ControlProperty);
        end
        
        function workaroundMatlabStrangeBugs(this, arg)
            % this workaround solves the issue with textboxes String
            % property not being updated by the time the KeyPress or
            % KeyRelease events are raised. When pressing enter the value
            % is set in the property, this workaround simulates a keyboard
            % enter key press to solve the issue.
            if isa(this.Control, 'matlab.ui.control.UIControl') &&  ...
               strcmp(this.Control.Style, 'edit') && ...
               ismember(this.ControlEvent, {'KeyRelease', 'KeyPress'})
                try
                    if ~isequal(arg.Key,'return')
                        import java.awt.Robot;
                        import java.awt.event.KeyEvent;
                        robot=Robot;
                        robot.keyPress(KeyEvent.VK_ENTER);
                        pauseState = pause('on');
                        pause(0.01);
                        robot.keyRelease(KeyEvent.VK_ENTER);
                        pause(0.01);
                        pause(pauseState);
                    end
                catch e
                    % should log this someday
                    % let's throw a warning for now...
                    warning('mvvm:Binder:Workaround:TextEdit:KeyboardEvent:failure', ...
                        'Failed to execute mvvm.Binder TextEdit KeyboardEvent workaround better look into it');
                end
            end
        end
        
        function value = extractValueFromModel(this, scope, path)
            [value, foundField] = mvvm.getobj(scope, path);
            
            if ~foundField
                originalCtrlValue = this.extractValueFromControl();
                expectedtype = class(originalCtrlValue);
                if ~strcmp(expectedtype, class(value))
                    value = feval([expectedtype '.empty']);
                end
            elseif ~isempty(this.ModelIndexer)
                value = this.ModelIndexer.getv(value);
            end
        end
        
        function doHandleModelUpdate(this, src, setPathIndex, raisedListenerIndex)
            this.bindData(src, this.ModelPath(setPathIndex:end));
        end
        
        function bindData(this, scope, path)
            value = this.extractValueFromModel(scope, path);
            set(this.Control, this.ControlProperty, value);
        end
        
        function parseConfiguration(this, control, args)
            % configure input parser
            parser = inputParser();
            parser.CaseSensitive = false;
            parser.FunctionName = class(this);
            
            % add all parameters to the parser
            this.prepareParser(parser);
            
            % parse input
            parse(parser, args{:});
            
            % extract all parsed parameters
            this.extractParserParameters(parser, control);
        end
        
        function extractParserParameters(this, parser, control)
            % first of all, get binding manager
            this.BindingManager = parser.Results.BindingManager;
            
            % get control event name
            this.ControlEvent = parser.Results.Event;
            
            % get update delay definitions
            if isequal(parser.Results.UpdateDelay, 0)
                this.ModelUpdateDelay = 0;
            else
                this.ModelUpdateDelay = parser.Results.UpdateDelay;
            end
            
            % get model provider
            if ~isempty(parser.Results.ModelProvider)
                this.ModelProvider = parser.Results.ModelProvider;
            else
                this.ModelProvider = this.BindingManager.getModelProvider(ancestor(control, 'figure'));
            end
            
            % get model accessor
            if ~isempty(parser.Results.Indexer)
                if isa(parser.Results.Indexer, 'mvvm.providers.IModelIndexer')
                    this.ModelIndexer = parser.Results.Indexer;
                else
                    this.ModelIndexer = mvvm.providers.ModelIndexer(parser.Results.Indexer{:});
                end
            end
        end
        
        function prepareParser(~, parser)
            % define parameters
            addParameter(parser, 'BindingManager', mvvm.BindingManager.instance(),...
                @(x) assert(isa(x, 'mvvm.BindingManager'), 'Binding manager must be a valid mvvm.BindingManager'));
            addParameter(parser, 'Event', '', ...
                @(x) assert(ischar(x), 'The controls event must be a name of a public event or event handler function property'));
            addParameter(parser, 'UpdateDelay', 0, @(x) assert(isnumeric(x) && isscalar(x) && x>=0, 'Update delay must be a positive number'));
            addParameter(parser, 'ModelProvider', mvvm.providers.SimpleModelProvider.empty(),...
                @(x) assert(isa(x, 'mvvm.providers.IModelProvider'), 'Model Provider must implement the mvvm.IModelProvider abstract class'));
            addParameter(parser, 'Indexer', mvvm.providers.IModelIndexer.empty(),...
                @(x) assert(isa(x, 'mvvm.providers.IModelIndexer') || mvvm.providers.ModelIndexer.validateIndex(x),...
                'Model Indexer must be implement the mvvm.providers.IModelProvider abstract class or be numeric, logical, string, char-vector or character cellarrays'));
        end
    end
end

