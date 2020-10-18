classdef TableScope < mvvm.scopes.Scope
    % A specialized scope which accesses the key-value pairs of a
    % containers.Map
    %
    % Author: TADA
    
    methods
        function this = TableScope(modelProvider, path, key, keyType)
            this@mvvm.scopes.Scope(modelProvider, path, key, keyType);
        end
    end
    
    methods (Access=protected)
        function keys = getKeys(this, list)
            keys = mvvm.scopes.TableScope.getKeysList(list);
        end
        
        function b = hasKey(this, list)
            if strcmp(this.KeyType, 'rownames')
                % check if has rowname
                b = ismember(this.Key,list.Properties.RowNames);
            else
            	b = hasKey@mvvm.scopes.Scope(this, list);
            end
        end
        
        function setItemInKey(this, list, value)
            if strcmp(this.KeyType, 'rownames')
                % set value in rowname
                list(this.Key,:) = value;

                if ~isa(list, 'handle')
                    this.updateList(list);
                end
            else
            	setItemInKey@mvvm.scopes.Scope(this, list, value);
            end
        end
        
        function scope = getItemInKey(this, list)
            if strcmp(this.KeyType, 'rownames')
                % get value in rowname
                scope = list(this.Key,:);
            else
            	scope = getItemInKey@mvvm.scopes.Scope(this, list);
            end
        end
    end
    
    methods (Static)
        function keys = getKeysList(list, type)
            switch type
                case 'rownames'
                    keys = list.Properties.RowNames;
                case 'cells'
                    throw(MException('mvvm:scopes:TableScope:InvalidKeyType', 'Linear indexing is not supported by tables'));
                otherwise
                    keys = mvvm.scopes.Scope.getKeysList(list, type);
            end
        end
    end
end