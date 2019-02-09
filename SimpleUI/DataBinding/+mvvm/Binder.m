classdef Binder < mvvm.ModelPathObserver
    %BIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        % This is a handle to a timer which will execute model update after
        % the control event fires and a certain timeout fires
        ModelUpdateTimer;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        BindingManager;
        Control;
        ControlProperty;
        ControlEvent;
        ControlDestroyedListener;
        ControlEventListener;
        ModelUpdateDelay;
    end
    
    methods
        
        function this = Binder(modelPath, control, property, varargin)
        % Constructs a data binder object and starts listening to
        % changes    
            % call base ctor
            this@mvvm.ModelPathObserver();
            
            % initialize binder
            this.init(modelPath, control, property, varargin);
        end
        
        function delete(this)
            % delete this
            delete@mvvm.ModelPathObserver(this);
            
            % dispose control listener
            if ~isempty(this.ControlEvent)
                if ~isempty(this.ControlEventListener)
                    % delete event listener
                    delete(this.ControlEventListener);
                    this.ControlEventListener = [];
                elseif isvalid(this.Control)
                    % remove event handler function
                    set(this.Control, this.ControlEvent, []);
                end
            end
            
            % delete update timer
            if ~isempty(this.ModelUpdateTimer)
                delete(this.ModelUpdateTimer);
                this.ModelUpdateTimer = [];
            end
            
            % decouple from binding manager
            if isvalid(this.BindingManager)
                this.BindingManager.clearBinder(this);
                this.BindingManager = [];
            end
        end
    end
    
    methods (Access=protected)
        function init(this, modelPath, control, property, args)
            % parse modular input usin varargin
            this.parseConfiguration(control, args);
            
            init@mvvm.ModelPathObserver(this, modelPath, this.ModelProvider);
            
            % configure binder-control interaction
            this.Control = control;
            this.ControlProperty = property;
            this.setupControlBinding();
            
            % when the control is destroyed, also terminate the binder
            this.ControlDestroyedListener = control.addlistener('ObjectBeingDestroyed', @(src, e) delete(this));
            
            % initial model 2 control binding
            this.bindData(this.ModelProvider.getModel(), this.ModelPath);
            
            % keep binder alive
            this.BindingManager.saveBinder(this);
        end
        
        function setupControlBinding(this)
            % configure binder delay on conrtol event being raise.
            if this.ModelUpdateDelay > 0
                this.ModelUpdateTimer = timer();
                this.ModelUpdateTimer.TimerFcn = @(~, ~) this.executeControlUpdate();
                this.ModelUpdateTimer.TasksToExecute = 1;
                this.ModelUpdateTimer.StartDelay = this.ModelUpdateDelay;
            end
            
            % control 2 model data binding
            if ~isempty(this.ControlEvent)
                this.bindControlEvent(this.Control, this.ControlEvent);
            end
        end
        
        function bindControlEvent(this, control, event)
            this.ControlEvent = event;
            
            % control callback handler function
            function listenerFunction(src, args)
                this.handleControlUpdate(args);
            end
            
            if isprop(control, event)
                % use callback properties api
                set(control, event, @listenerFunction);
            else
                % use event listeners api for events
                this.ControlEventListener = control.addlistener(event, @listenerFunction);
            end
        end
        
        function handleControlUpdate(this, args)
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
        
        function executeControlUpdate(this)
        % updates the model on control update event
            value = get(this.Control, this.ControlProperty);
            scope = this.ModelProvider.getModel();
            [rescope, didLocateHandle] = mvvm.setobj(scope, this.ModelPath, value);
            if ~didLocateHandle
                this.ModelProvider.setModel(rescope);
            end
        end
        
        function doHandleModelUpdate(this, src, args, setPathIndex, raisedListeberIndex)
            this.bindData(args.AffectedObject, this.ModelPath(setPathIndex:end));
        end
        
        function bindData(this, scope, path)
            value = mvvm.getobj(scope, path);
            set(this.Control, this.ControlProperty, value);
        end
        
        function parseConfiguration(this, control, args)
            % configure input parser
            parser = inputParser();
            parser.CaseSensitive = false;
            parser.FunctionName = 'mvvm.Binder';
            
            % define parameters
            addParameter(parser, 'BindingManager', mvvm.BindingManager.instance(),...
                @(x) assert(isa(x, 'mvvm.BindingManager'), 'Binding manager must be a valid mvvm.BindingManager'));
            addParameter(parser, 'Event', '', ...
                @(x) assert(ischar(x), 'The controls event must be a name of a public event or event handler function property'));
            addParameter(parser, 'UpdateDelay', 0, @(x) assert(isnumeric(x) && isscalar(x) && x>=0, 'Update delay must be a positive number'));
            addParameter(parser, 'ModelProvider', mvvm.providers.SimpleModelProvider.empty(),...
                @(x) assert(isa(x, 'mvvm.providers.IModelProvider'), 'Model Provider must implement the mvvm.IModelProvider abstract class'));
            
            % parse input
            parse(parser, args{:});
            
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
                this.ModelProvider = this.BindingManager.getModelProvider(mvvm.getContainingFigure(control));
            end
        end
    end
end

