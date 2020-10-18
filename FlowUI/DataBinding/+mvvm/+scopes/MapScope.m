classdef MapScope < mvvm.scopes.Scope
    % A specialized scope which accesses the key-value pairs of a
    % containers.Map
    %
    % Author: TADA
    
    methods
        function this = MapScope(modelProvider, path, key)
            this@mvvm.scopes.Scope(modelProvider, path, key, 'cells');
        end
    end
    
    methods (Access=protected)
        function keys = getKeys(this, list)
            keys = mvvm.scopes.MapScope.getKeysList(list);
        end
        
        function b = hasKey(this, list)
            b = list.isKey(this.Key);
        end
        
        function setItemInKey(this, list, value)
            % set value for the specified key
            list(this.Key) = value;
            warning('mvvm:Scope:ContainersMapIssue', 'containers.Map doesn''t implement change events, use lists.Map instead');
        end
        
        function scope = getItemInKey(this, list)
            % get value for the specified key
            scope = list(this.Key);
            warning('mvvm:Scope:ContainersMapIssue', 'containers.Map doesn''t implement change events, use lists.Map instead');
        end
    end
    
    methods (Static)
        function keys = getKeysList(list, keyType)
            keys = list.keys;
        end
    end
end

