classdef (Abstract) ICache < handle
    % gen.ICache is an interface for cross-layer caching implementations
    
    methods (Abstract)
        % clears the entire cache
        clearCache(this);
        
        % Gets a value stored in cache
        value = get(this, key);
        
        % Stores the value in cache
        set(this, key, value);
        
        % Removes a stored value from the cache
        removeEntry(this, key);
        
        % Determines whether the cache stores a value with the specified
        % key
        containsKey = hasEntry(this, key);
        
        % Gets all stored keys
        keys = allKeys(this);
        
        % Gets all stored values
        items = allValues(this);
    end
end

