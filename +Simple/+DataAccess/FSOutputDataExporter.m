classdef (Abstract) FSOutputDataExporter < handle
    
    methods
        function this = FSOutputDataExporter()
            Simple.obsoleteWarning('Simple.DataAccess');
        end
    end
    
    methods (Abstract)
        % save(this, data, path) - exports data into the specified path
        % save(this, data, output, path) - exports data and output into the specified path
        save(this, data, a, b)
        
        [data, output] = load(this, path)
        
        postfix = outputFilePostfix(this)
    end
end

