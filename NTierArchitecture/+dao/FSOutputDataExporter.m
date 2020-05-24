classdef (Abstract) FSOutputDataExporter < handle
    
    methods (Abstract)
        % save(this, data, path) - exports data into the specified path
        save(this, data, path)
        
        [data, output] = load(this, path)
        
        postfix = outputFilePostfix(this)
    end
end

