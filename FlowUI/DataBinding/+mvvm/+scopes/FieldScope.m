classdef FieldScope < mvvm.scopes.Scope
    % A specialized scope which accesses the fields/properties/variables of
    % a struct/object/table as list items
    %
    % Author: TADA
    
    methods
        function this = FieldScope(modelProvider, path, key)
            this@mvvm.scopes.Scope(modelProvider, path, key, 'fieldnames');
        end
    end
    
    methods (Access=protected)
        function keys = getKeys(this, list)
            keys = mvvm.scopes.FieldScope.getKeysList(list);
        end
        
        function b = hasKey(this, list)
            key = this.Key;
            b = (istable(list) && ismember('LastName', list.Properties.VariableNames)) || ...
                (isobject(list) && isprop(list, key)) || ...
                (isstruct(list) && isfield(list, key));
        end
        
        function setItemInKey(this, list, value)
            % set property/field
            list.(this.Key) = value;

            % prevent model update of a list which is actually a handle scalar
            if ~isa(list, 'handle')
                % update the list in the model scope
                this.updateList(list);
            end
        end
        
        function scope = getItemInKey(this, list)
            % get property/field
            scope = list.(this.Key);
        end
    end
    
    methods (Static)
        function keys = getKeysList(list)
            if istable(list)
                keys = list.Properties.VariableNames;
            elseif isstruct(list)
                keys = fieldnames(list);
            elseif isobject(list)
                keys = properties(list);
            else
                throw(MException('mvvm:scopes:FieldScope:InvalidList', ...
                    'mvvm.scopes.FieldScope can only support keys for tables, structs and objects'));
            end
        end
    end
end

