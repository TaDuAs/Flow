classdef AppContext < gen.Cache & mvvm.IAppContext
    % mvvm.AppContext holds the context for application domains
    
    properties
        IocContainer IoC.IContainer = IoC.Container.empty();
    end
    
    methods
        function this = AppContext(ioc)
            if nargin < 1; ioc = IoC.Container.empty(); end
            this@gen.Cache();
            this.IocContainer = ioc;
        end
    end
    
    methods % lists.IDictionary
        function clear(this)
            this.clearCache();
        end
        
        function tf = isKey(this, key)
            tf = this.hasEntry(key);
        end
        
        function keySet = keys(this)
            keySet = this.allKeys();
        end
        
        function valueSet = values(this)
            valueSet = this.allValues();
        end
        
        function n = length(this)
            n = numel(this.allKeys);
        end
        
        function tf = isempty(this)
            tf = this.length() == 0;
        end
        
        function s = size(this, dim)
            if nargin >= 2
                s = this.length();
            else
                s = [1, this.length()];
            end
        end
        
        function value = getv(this, i)
            value = this.get(i);
        end
        
        function setv(this, i, value)
            this.set(i, value);
        end
        
        function add(this, key, value)
            this.setv(key, value);
        end
        
        function removeAt(this, i)
            this.removeEntry(i);
        end
        
        function setVector(this, keys, values)
            % clear context
            this.clearCache();
            
            % set new context
            for i = 1:numel(keys)
                if iscell(values)
                    currValue = values{i};
                else
                    currValue = value(i);
                end
                
                if iscell(keys)
                    currKey = keys{i};
                else
                    currKey = keys(i);
                end
                
                this.add(currKey, currValue);
            end
        end
    end
end

