classdef DefaultScopeFactory < mvvm.scopes.IScopeFactory
    properties
        KeyType;
        ManageSequentialIndices = true;
    end
    
    methods % Property accessors
        function this = set.KeyType(this, value)
            mvvm.scopes.DefaultScopeFactory.validateKeyType(value);
            this.KeyType = value;
        end
    end
    
    methods
        function this = DefaultScopeFactory(keyType)
            if nargin < 1
                this.KeyType = 'default';
            else
                this.KeyType = keyType;
            end
        end
        
        function scope = build(this, modelProvider, path, list, key)
            % lists.IObservable triumphs over all other options
            % because of the observability of the collection
            if isa(list, 'lists.IObservable')
                scope = mvvm.scopes.CollectionScope(modelProvider, path, key);
                scope.ManageKeyUpdates = this.ManageSequentialIndices && isa(list, 'lists.ISequentialKeys');
                if ~strcmp(this.KeyType, 'default')
                    warning('mvvm:scopes:DefaultScopeFactory:InvalidKeyType',...
                        'lists.IObservable controls its own key types, the scope has no power over lists.IObservable indexing method');
                end
            % for containers.Map the KeyType makes no difference
            elseif isa(list, 'containers.Map')
                scope = mvvm.scopes.MapScope(modelProvider, path, key);
                if ~strcmp(this.KeyType, 'default')
                    warning('mvvm:scopes:DefaultScopeFactory:InvalidKeyType',...
                        'containers.Map controls its own key types, the scope has no power over containers.Map indexing method');
                end
            elseif strcmp(this.KeyType, 'fieldnames')
                scope = mvvm.scopes.FieldScope(modelProvider, path, key);
            elseif istable(list)
                scope = mvvm.scopes.TableScope(modelProvider, path, key, this.KeyType);
            else
                if strcmp(this.KeyType, 'default') && (isobject(list) || isstruct(list))
                    keyType = 'cells';
                else
                    keyType = this.KeyType;
                end
                
                scope = mvvm.scopes.Scope(modelProvider, path, key, keyType);
            end
        end
        
        function keySet = getKeys(this, list)
        % Gets a keySet for the given list according to the KeyType and the
        % list type
        %
        % Note about key set generation:
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
            if isa(list, 'lists.IObservable')
                keySet = mvvm.scopes.CollectionScope.getKeysList(list);
            % for containers.Map the KeyType makes no difference
            elseif isa(list, 'containers.Map')
                keySet = mvvm.scopes.MapScope.getKeysList(list);
            elseif strcmp(this.KeyType, 'fieldnames')
                keySet = mvvm.scopes.FieldScope.getKeysList(list);
            elseif istable(list)
                keySet = mvvm.scopes.TableScope.getKeysList(list, this.KeyType);
            else
                keySet = mvvm.scopes.Scope.getKeysList(list, this.KeyType);
            end
        end
    end
    
    methods (Static)
        function validateKeyType(value)
            assert(ismember(value, {'default', 'rows', 'cols', 'cells', 'rownames', 'fieldnames'}),...
                'IndexingMethod must be either of ''default'', ''rows'', ''cols'', ''cells'', ''rownames'', ''fieldnames''');
        end
    end
end

