classdef Cache < gen.ICache
    % gen.Cache implements context for cross-layer in-memory cache storage
    
    properties (Access=private)
        Context containers.Map;
    end
    
    methods
        function this = Cache()
            this.Context = containers.Map();
        end
    
        function clearCache(this)
        % Clears the entire cache storage
            this.Context.remove(this.Context.keys);
        end
        
        function value = get(this, key)
        % Gets an entry from the context object holder
            if this.hasEntry(key)
                value = this.Context(key);
            else
                value = [];
            end
        end
        
        function set(this, key, value)
        % Sets specified value in an entry in the context object holder
            this.Context(key) = value;
        end
        
        function removeEntry(this, key)
        % removes a stored entry from cache
            if this.hasEntry(key)
                this.Context.remove(key);
            end
        end
        
        function containsKey = hasEntry(this, key)
        % Determines whether a specific key exists in the context object
        % holder
            containsKey = this.Context.isKey(key);
        end
        
        function keys = allKeys(this)
        % Gets all the stored keys
            keys = this.Context.keys;
        end
        
        function items = allValues(this)
        % Gets all stored values
            items = this.Context.values;
        end
    end
    
end

