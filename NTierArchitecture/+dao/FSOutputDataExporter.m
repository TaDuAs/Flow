classdef (Abstract) FSOutputDataExporter < handle
    
    methods (Abstract)
        % save(this, data, path) - exports data into the specified path
        save(this, data, output, path)
        
        [data, output] = load(this, path)
        
        postfix = outputFilePostfix(this)
    end
    
    methods (Access=protected)
        function outputFilePath = generateOutputDataFilePath(this, path)
            tok = regexp(path, '^(.+)\.([a-zA-Z]+)$', 'tokens');
            pathAndName = tok{1}{1};
            postfix = tok{1}{2};
            outputFilePath = [pathAndName '_output.' postfix];
        end
    end
end

