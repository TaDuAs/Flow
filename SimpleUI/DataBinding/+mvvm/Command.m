classdef Command < mvvm.ControlObserver & mvvm.IBinderBase
    
    properties (Access=protected)
        DynamicParamsMask;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        ActionModelPath;
        ModelProvider;
        BindingManager;
        DynamicParams;
        ConstantParams;
    end
    
    methods
        function this = Command(actionModelPath, control, event, varargin)
            this@mvvm.ControlObserver();
            
            this.parseConfiguration(control, varargin);
            
            this.init(actionModelPath, control, event);
        end
        
        function delete(this)
            if ~isvalid(this)
                return;
            end
            
            % decouple from binding manager
            if ~isempty(this.BindingManager) && isvalid(this.BindingManager)
                this.BindingManager.clearBinder(this);
                this.BindingManager = [];
            end
            
            % delete base class stuff
            delete@mvvm.ControlObserver(this);
        end
    end
    
    methods (Access=protected)
        function handleControlUpdate(this, arg)
            model = this.ModelProvider.getModel();
            actionScope = mvvm.getobj(model, this.ActionModelPath(1:end-1));
            
            % build input variables
            params = cell(size(this.DynamicParamsMask));
            params(this.DynamicParamsMask) = cellfun(@getModel, this.DynamicParams, 'UniformOutput', false);
            params(~this.DynamicParamsMask) = this.ConstantParams;
            
            % activate action
            actionScope.(this.ActionModelPath{end})(params{:});
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
            
            % get model provider
            if ~isempty(parser.Results.ModelProvider)
                this.ModelProvider = parser.Results.ModelProvider;
            else
                this.ModelProvider = this.BindingManager.getModelProvider(ancestor(control, 'figure'));
            end
            
            % get parameters
            dynamicParamsMask = cellfun(@(c) isa(c, 'mvvm.providers.IModelProvider'), parser.Results.Params);
            this.ConstantParams = parser.Results.Params(~dynamicParamsMask);
            this.DynamicParams = parser.Results.Params(dynamicParamsMask);
            this.DynamicParamsMask = dynamicParamsMask;
        end
        
        function prepareParser(~, parser)
            % define parameters
            addParameter(parser, 'BindingManager', mvvm.BindingManager.instance(),...
                @(x) assert(isa(x, 'mvvm.BindingManager'), 'Binding manager must be a valid mvvm.BindingManager'));
            addParameter(parser, 'ModelProvider', mvvm.providers.SimpleModelProvider.empty(),...
                @(x) assert(isa(x, 'mvvm.providers.IModelProvider'), 'Model Provider must implement the mvvm.IModelProvider abstract class'));
            addParameter(parser, 'Params', {}, @(x) assert(iscell(x) && isrow(x), 'Params property must be a row cell array'));
        end
        
        function init(this, actionModelPath, control, event)
            if ischar(actionModelPath)
                this.ActionModelPath = strsplit(actionModelPath, '.');
            elseif iscellstr(actionModelPath)
                this.ActionModelPath = actionModelPath;
            else
                throw(MException('mvvm:Command:InvalidActionModelPath', ...
                    'ActionModelPath must be a list of property names as a cell array of character vectors or as a character vector separated by ''.'' with the last being the name of the method or property holding a function handle'));
            end
            
            init@mvvm.ControlObserver(this, control, event);
            
            % setup the control binding
            this.setupControlBinding();
            
            % keep command binder alive
            this.BindingManager.saveBinder(this);
        end
    end
end

