classdef CollectionScope < mvvm.scopes.Scope
    % A specialized scope which accesses collection classes which implement
    % the scol.observable.ICollection abstract class
    %
    % Author: TADA
    
    properties (GetAccess=public,SetAccess=protected)
        Collection scol.observable.ICollection = scol.observable.ObservableArray.empty();
        CollectionListener;
    end
    
    methods
        function this = CollectionScope(modelProvider, path, key)
            % the collection controls it's own key set and indexing type,
            % so keytype is irrelevant here, call base ctor with the
            % default keytpye controlled by mvvm.scopes.Scope - it will
            % never be used...
            this@mvvm.scopes.Scope(modelProvider, path, key);
        end
    end
    
    methods (Access=protected)
        function bindModelEvents(this, startAt)
            if nargin < 2; startAt = []; end
            bindModelEvents@mvvm.scopes.Scope(this, startAt);
            
            list = this.getList();
            % if the collection was replaced, or the event listener is
            % dead, create a new listener
            if isempty(this.Collection) || ~eq(list, this.Collection) || isempty(this.CollectionListener) || ~isvalid(this.CollectionListener)
                this.Collection = list;
                delete(this.CollectionListener);
                if isempty(list)
                    this.CollectionListener = [];
                else
                    this.CollectionListener = list.addlistener('collectionChanged', @(src, arg) this.onCollectionChanged(arg));
                end
            end
        end
        
        function onCollectionChanged(this, eArg)
            if ismember(this.Key, eArg.i)
                switch eArg.Action
                    case 'remove'
                        notify(this, 'scopeRemoved');
                    case 'change'
                        notify(this, 'modelChanged');
                end
            end
        end
        
        function keys = getKeys(this, list)
            keys = mvvm.scopes.CollectionScope.getKeysList(list);
        end
        
        function b = hasKey(this, list)
            b = list.containsIndex(this.Key);
        end
        
        function setItemInKey(this, list, value)
            % set value for the specified key
            list.setv(value, this.Key);
        end
        
        function scope = getItemInKey(this, list)
            % get value for the specified key
            scope = list.getv(this.Key);
        end
    end
    
    methods (Static)
        function keys = getKeysList(list)
            keys = list.keys;
        end
    end
end