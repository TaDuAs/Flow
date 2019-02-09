classdef Scope < mvvm.ModelPathObserver & mvvm.providers.IModelProvider
    % mvvm.scopes.Scope provides access to elements in lists in a model
    % Provides the default functionality for the builtin matlab types:
    %       - table
    %       - cell array
    %       - matix
    % Provides functionality for scalar handle list classes which implement 
    % subsref & subsasgn
    % 
    % Author: TADA 2019
    
    events
        scopeRemoved;
    end
    
    properties (GetAccess=public,SetAccess=protected)
        Key;
        KeyType;
    end
    
    methods
        function this = Scope(modelProvider, path, key, keyType)
            this@mvvm.ModelPathObserver();
            this.Key = key;
            if nargin < 4 || isempty(keyType) || strcmp(keyType, 'default')
                this.KeyType = 'rows';
            else
                this.KeyType = keyType;
            end
            
            this.init(path, modelProvider);
        end
        
        % Gets the model from persistence layer
        function scope = getModel(this)
            list = this.getList();
            
            if isempty(list)
                scope = [];
            else
                scope = this.getItemInKey(list);
            end
        end
        
        % Sets the model in persistence layer
        function setModel(this, scope)
            list = this.getList();
            this.setItemInKey(list, scope);
        end
    end
    
    methods (Access=protected)
        function keys = getKeys(this, list)
            keys = mvvm.scopes.Scope.getKeysList(list, this.KeyType);
        end
        
        function list = getList(this)
            model = this.ModelProvider.getModel();
            list = mvvm.getobj(model, this.ModelPath);
        end
        
        function doHandleModelUpdate(this, src, args, setPathIndex, raisedListenerIndex)
            if ~this.hasKey(this.getList())
                notify(this, 'scopeRemoved');
            else
                notify(this, 'modelChanged');
            end
        end
        
        function updateList(this, list)
            model = this.ModelProvider.getModel();
            [model, locatedHandle] = mvvm.setobj(model, this.ModelPath, list);
            
            if ~locatedHandle
                this.ModelProvider.setModel(model);
            end
        end
        
        function b = hasKey(this, list)
            key = this.Key;
            switch this.KeyType
                case 'rows'
                    b = key <= size(list, 1);
                case 'cols'
                    b = key <= size(list, 2);
                case 'cells'
                    b = key <= numel(list);
            end
        end
        
        function setItemInKey(this, list, value)
            key = this.Key;
            switch this.KeyType
                case 'rows'
                    list(key,:) = value;
                case 'cols'
                    list(:,key) = value;
                case 'cells'
                    if iscell(list)
                        list{key} = value;
                    else
                        list(key) = value;
                    end
            end
            
            % prevent model update for a scalar handle that overrides
            % subsasgn
            if isscalar(list) && isa(list, 'handle') && ismethod(list, 'subsasgn')
                return;
            end
            
            % update the list in the model scope
            this.updateList(list);
        end
        
        function scope = getItemInKey(this, list)
            key = this.Key;
             switch this.KeyType
                case 'rows'
                    scope = list(key,:);
                case 'cols'
                    scope = list(:,key);
                case 'cells'
                    if iscell(list)
                        scope = list{key};
                    else
                        scope = list(key);
                    end
                 otherwise
                     throw(MException('mvvm:scopes:Scope:InvalidKeyType', 'mvvm.scopes.Scope supported key types are ''rows'', ''cols'' and ''cells'''));
            end
        end
    end
    
    methods (Static)
        % static functions are evil, but a Scope instance revolves around
        % having a key. Therefore having the Scope instance generate the
        % list of keys is a problem.
        % If the ScopeFactory would generate the keys, the Scope may need
        % to know it's builder which is a strong coupling I'm not
        % interested in.
        % Could have gone with an IScopeKeyGen interface and specialized
        % classes, this abstraction would have been elegant, but seems like
        % a bit of an overkill at the moment.
        % The solution right now is that each specialized Scope class
        % statically generates the keys. The scope instance can use it's 
        % own class' static method to generate the key when it needs to. 
        % The scope builder which already is strongly coupled to all the 
        % specialized scope classes because it constructs them will have 
        % to call their static methods to generate the keys.
        function keys = getKeysList(list, type)
            if nargin < 2 || isempty(type); type = 'rows'; end
            
            switch type
                case {'rows', 'default'}
                    keys = 1:size(list, 1);
                case 'cols'
                    keys = 1:size(list, 2);
                case 'cells'
                    keys = 1:numel(list);
                otherwise
                    throw(MException('mvvm:scopes:Scope:InvalidKeyType', 'mvvm.scopes.Scope supported key types are ''rows'', ''cols'' and ''cells'''));
            end
        end
    end
end

