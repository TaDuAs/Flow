classdef (Abstract) IDictionary < lists.ICollection
    methods (Abstract)
        % adds a new item to the dictionary
        add(this, key, value);
        
        % replaces all items in the dictionary with a new key-value set
        setVector(this, keys, vector);
        
        % clears the dictionary
        clear(this);
        
        % Gets all stored keys
        keys = keys(this);
        
        % Gets all stored values
        items = values(this);
        
        % Determines whether the cache stores a value with the specified
        % key
        containsKey = isKey(this, key);
    end
end

