classdef MessageBinder < mvvm.ModelPathObserver & mvvm.IBinderBase
    % mvvm.MessageBinder is a binder which is not bound to a GUI element.
    % Instead of updating the GUI like mvvm.Binder does, mvvm.MessageBinder
    % raises a callback once the binding event is raised.
    
    properties
        % Callback function with the signature:
        % function callback(model, flag)
        %   # model is the value extracted from the model under the binding
        %   model path.
        %   # flag is a logical scalar which determines whther the model path
        %   was successfully accessed. if flag is false, that means the
        %   scope of this binder cannot be accessed due to an object on the
        %   model path being empty.
        Callback function_handle;
        
        Control;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        BindingManager mvvm.IBindingManager = mvvm.BindingManager.empty();
        ModelIndexer mvvm.providers.IModelIndexer;
    end
    
    methods
        function this = MessageBinder(modelPath, callback, control, varargin)
            % call base ctor
            this@mvvm.ModelPathObserver();
            
            this.Callback = callback;
            this.Control = control;
            
            % parse modular input using varargin
            this.parseConfiguration(control, varargin);
            
            % initialize binder
            this.init(modelPath);
        end
        
        function delete(this)
            if ~isvalid(this)
                return;
            end
            
            % delete this
            delete@mvvm.ModelPathObserver(this);
            
            % decouple from binding manager
            if ~isempty(this.BindingManager) && isvalid(this.BindingManager)
                this.BindingManager.clearBinder(this);
                this.BindingManager = mvvm.BindingManager.empty();
            end
        end
        
        function start(this, what)
            if nargin < 2 || isempty(what); what = 'all'; end
            
            if any(strcmp(what, {'all', 'model'}))
                start@mvvm.ModelPathObserver(this);
            end
        end
        
        function stop(this, what)
            if nargin < 2 || any(strcmp(what, {'all', 'model'}))
                stop@mvvm.ModelPathObserver(this);
            end
        end
        
        function tf = isSubjectToControl(this, control)
        % determines whether this observes the given control or one of its
        % descendants
            tf = mvvm.isChildOf(this.Control, control);
        end
    end
    
    methods (Access=protected)
        function init(this, modelPath)
            init@mvvm.ModelPathObserver(this, modelPath, this.ModelProvider);
            
            % keep binder alive
            this.BindingManager.saveBinder(this);
        end
        
        function [value, foundField] = extractValueFromModel(this, scope, path)
            [value, foundField] = mvvm.getobj(scope, path);
            
            if foundField && ~isempty(this.ModelIndexer)
                value = this.ModelIndexer.getv(value);
            end
        end
        
        function doHandleModelUpdate(this, scope, setPathIndex, raisedListenerIndex)
            this.sendMessage(scope, this.ModelPath(setPathIndex:end));
        end
        
        function sendMessage(this, scope, path)
            [value, didFindField] = this.extractValueFromModel(scope, path);
            this.Callback(value, didFindField);
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
            bm = parser.Results.BindingManager;
            if ~isempty(bm)
                this.BindingManager = parser.Results.BindingManager;
            else
                this.BindingManager = mvvm.GlobalBindingManager.instance();
            end
            
            % get model provider
            if ~isempty(parser.Results.ModelProvider)
                this.ModelProvider = parser.Results.ModelProvider;
            else
                this.ModelProvider = this.BindingManager.getModelProvider(control);
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
            addParameter(parser, 'BindingManager', mvvm.BindingManager.empty(),...
                @(x) assert(isvalid(x) && isa(x, 'mvvm.IBindingManager'), 'Binding manager must be a valid mvvm.IBindingManager'));
            addParameter(parser, 'ModelProvider', mvvm.providers.SimpleModelProvider.empty(),...
                @(x) assert(isa(x, 'mvvm.providers.IModelProvider'), 'Model Provider must implement the mvvm.IModelProvider abstract class'));
            addParameter(parser, 'Indexer', mvvm.providers.IModelIndexer.empty(),...
                @(x) assert(isa(x, 'mvvm.providers.IModelIndexer') || mvvm.providers.ModelIndexer.validateIndex(x),...
                'Model Indexer must be implement the mvvm.providers.IModelProvider abstract class or be numeric, logical, string, char-vector or character cellarrays'));
        end
    end
end

