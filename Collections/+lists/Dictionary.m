classdef Dictionary < lists.IDictionary
        % gen.Cache implements context for cross-layer in-memory cache storage
    
    properties (Access=private)
        Container containers.Map;
    end
    
    methods
        function this = Dictionary()
            this.Container = containers.Map();
        end
    
        function clear(this)
        % Clears the entire cache storage
            this.Container.remove(this.keys);
        end
        
        function value = getv(this, key)
        % Gets an entry from the context object holder
            if this.isKey(key)
                value = this.Container(key);
            else
                value = [];
            end
        end
        
        function setv(this, key, value)
        % Sets specified value in an entry in the context object holder
            this.Container(key) = value;
        end
        
        function removeAt(this, key)
        % removes a stored entry from cache
            if this.isKey(key)
                this.Container.remove(key);
            end
        end
        
        function tf = isKey(this, key)
        % Determines whether a specific key exists in the context object
        % holder
            tf = this.Container.isKey(key);
        end
        
        function keys = keys(this)
        % Gets all the stored keys
            keys = this.Container.keys;
        end
        
        function items = values(this)
        % Gets all stored values
            items = this.Container.values;
        end
        
        
        function setVector(this, keys, values)
            this.clear();
            
            for i = 1:numel(keys)
                if iscell(values)
                    currValue = values{i};
                else
                    currValue = values(i);
                end
                
                if iscell(keys)
                    currKey = keys{i};
                else
                    currKey = keys(i);
                end
                
                this.add(currKey, currValue);
            end
        end
        
        function add(this, key, value)
            this.setv(key, value);
        end
        
        function n = size(this, dim)
            if nargin < 2
                n = size(this.keys());
            else
                n = size(this.keys(), dim);
            end
        end
        
        function tf = isempty(this)
            tf = this.length() == 0;
        end
        
        function l = length(this)
            l = numel(this.keys());
        end
    end
end

