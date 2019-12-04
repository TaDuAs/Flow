classdef (Abstract) IScopeFactory
    methods (Abstract)
        scope = build(scopeFactory, modelProvider, path, list, key);
        keys = getKeys(scopeFactory, list);
    end
end

