classdef Repeater < mvvm.Binder
    % 
    
    properties (GetAccess=protected,SetAccess=protected)
        ScopeList;
        ScopeRemovedListeners;
        UIComponents;
        CollectionListener;
        Collection;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        Template;
        ScopeFactory;
    end
    
    methods
        function this = Repeater(modelPath, control, template, varargin)
            this@mvvm.Binder(modelPath, control, '', template, varargin{:});
        end
        
        function delete(this)
            delete@mvvm.Binder(this);
            
            % terminate all repeater ui components
            for i = 1:numel(this.ScopeList)
                this.Template.teardown(this.ScopeList{i}, this.Control, this.UIComponents{i});
            end
            this.UIComponents = [];
            
            % terminate scope listeners
            cellfun(@delete, this.ScopeRemovedListeners);
            this.ScopeRemovedListeners = {};
            
            % terminate scopes
            cellfun(@delete, this.ScopeList);
            this.ScopeList = [];
            
            % terminate collection listener
            if ~isempty(this.CollectionListener)
                delete(this.CollectionListener)
                this.CollectionListener = [];
            end
            this.Collection = [];
            
            % clean up the rest of it
            this.Template = [];
            this.ScopeFactory = [];
        end
    end
    
    methods (Access=protected)
        function bindData(this, changedScope, path)
            notify(this, 'binding');
            
            list = mvvm.getobj(changedScope, path);
            
            % observe lists implementing lists.IObservable
            % when list changes, dispose the listener and create a new one
            % if possible.
            if ~isa(list, 'lists.IObservable') || ...
               ~isa(this.Collection, 'lists.IObservable') || ...
               ~any(eq(this.Collection, list))
                if ~isempty(this.CollectionListener) && isvalid(this.CollectionListener)
                    delete(this.CollectionListener);
                    this.CollectionListener = [];
                end
                if isa(list, 'lists.IObservable')
                    this.CollectionListener = list.addlistener('collectionChanged', @(src, arg) this.onCollectionChanged(src, arg));
                end
                this.Collection = list;
            end
            
            % when list is empty, stop here.
            % removed\changed items are monitored by the scopes, and
            % obviously there are no new items in empty lists.
            if isempty(list)
                return;
            end
            
            % get the new key set from the list
            newKeySet = this.ScopeFactory.getKeys(list);
            
            % if the new key set must be represented by a cell array, so
            % must the old key set.
            if iscell(newKeySet)
                oldKeySet = cellfun(@(s) s.Key, this.ScopeList, 'UniformOutput', false);
            else
                oldKeySet = cellfun(@(s) s.Key, this.ScopeList);
            end
            
            % detect newly added items
            newItemsKeys = setdiff(newKeySet, oldKeySet);
            
            % generate scopes for the new items and bind the scopes to the
            % template
            this.bindNewScopes(list, newItemsKeys);
            
            % Currently scopes monitor model updates and removal
            % I may change that in the future if the excess of event 
            % listeners proves to be too much of an overhead
%             removedItemsKeys = setdiff(oldKeySet, newKeySet);
%             changedItemsKeys = intersect(oldKeySet, newKeySet);
            
            notify(this, 'postBind');
        end
        
        function bindNewScopes(this, list, newItemsKeys)
            for key = newItemsKeys
                % Code Analyzer, please stop lying to me, there is no real
                % loop index in Matlab for loops, this is a foreach loop.
                % And I know what I'm doing, so don't worry about it.
                if iscell(key); key = key{1}; end
                
                i = numel(this.ScopeList) + 1;
                
                % generate scope for the new item
                scope = this.ScopeFactory.build(this.ModelProvider, this.ModelPath, list, key);
                this.ScopeList{i} = scope;
                
                % Scopes monitor item removal, register to item removal
                % notification to destroy the scope and the controls
                this.ScopeRemovedListeners{i} = scope.addlistener('scopeRemoved', @(src, arg) this.handleItemRemoved(src));
                
                % bind that scope to the template
                this.UIComponents{i} = this.Template.build(scope, this.Control);
            end
        end
        
        function onCollectionChanged(this, list, arg)
            switch arg.Action
                case 'add'
                    this.bindNewScopes(list, arg.i);
%                 case 'remove'
%                     notify(this, 'scopeRemoved');
%                 case 'change'
%                     notify(this, 'modelChanged');
            end
        end
        
        function handleItemRemoved(this, scope)
            i = cellfun(@(s) eq(s,scope), this.ScopeList);
            
            % terminate scope removed listener
            delete(this.ScopeRemovedListeners{i});
            this.ScopeRemovedListeners(i) = [];
            
            % teardown UI components
            this.Template.teardown(scope, this.Control, this.UIComponents{i});
            this.UIComponents(i) = [];
            
            % terminate the scope
            delete(this.ScopeList{i});
            this.ScopeList(i) = [];
        end
        
        function init(this, modelPath, control, property)
            this.ScopeList = {};
            this.ScopeRemovedListeners = {};
            
            init@mvvm.Binder(this, modelPath, control, property);
        end
        
        function prepareParser(~, parser)
            % mvvm.Repeater ctor injects the template into the args cell
            % array in the first position.
            addRequired(parser, 'Template',...
                @(x) assert(isa(x, 'mvvm.ITemplate') || isa(x, 'function_handle'), 'Template must be a function handle or a class which implements the mvvm.ITemplate abstract class'));
            
            % define optional parameters
            addParameter(parser, 'BindingManager', mvvm.BindingManager.empty(),...
                @(x) assert(isa(x, 'mvvm.IBindingManager'), 'Binding manager must be a valid mvvm.IBindingManager'));
            addParameter(parser, 'ModelProvider', mvvm.providers.SimpleModelProvider.empty(),...
                @(x) assert(isa(x, 'mvvm.providers.IModelProvider'), 'Model Provider must implement the mvvm.providers.IModelProvider abstract class'));
            addParameter(parser, 'IndexingMethod', '', @mvvm.scopes.DefaultScopeFactory.validateKeyType);
            addParameter(parser, 'ScopeFactory', mvvm.scopes.DefaultScopeFactory.empty(),...
                @(x) assert(isa(x, 'mvvm.scopes.IScopeFactory'), 'Scope factory must implement the mvvm.scopes.IScopeFactory abstract class'));
        end
        
        function extractParserParameters(this, parser, control)
            % first of all, get binding manager
            bm = parser.Results.BindingManager;
            if ~isempty(bm)
                this.BindingManager = parser.Results.BindingManager;
            else
                this.BindingManager = mvvm.GlobalBindingManager.instance();
            end
            
            % get the template which was injected into args in the ctor
            if isa(parser.Results.Template, 'function_handle')
                this.Template = mvvm.FHandleTemplate(parser.Results.Template);
            else
                this.Template = parser.Results.Template;
            end
            
            % get model provider
            if ~isempty(parser.Results.ModelProvider)
                this.ModelProvider = parser.Results.ModelProvider;
            else
                this.ModelProvider = this.BindingManager.getModelProvider(control);
            end
            
            % get scope factory
            if ~isempty(parser.Results.ScopeFactory)
                if ~isempty(parser.Results.IndexingMethod)
                    throw(MException('mvvm:Repeater:ConfigError', 'May only set scope factory or indexing method, but not both'));
                end
                this.ScopeFactory = parser.Results.ScopeFactory;
            else
                indexingMethod = parser.Results.IndexingMethod;
                if isempty(indexingMethod); indexingMethod = 'default'; end
                this.ScopeFactory = mvvm.scopes.DefaultScopeFactory(indexingMethod);
            end
            
            % these are not relevant for repeaters
            this.ControlEvent = '';
            this.ModelUpdateDelay = 0;
        end
    end
end

