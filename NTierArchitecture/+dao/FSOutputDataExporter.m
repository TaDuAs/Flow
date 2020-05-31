classdef (Abstract) FSOutputDataExporter < dao.IExImportDAO
    % FSOutputDataExporter extends the dao.IExImportDAO data import export
    % interace for specific import/export to/from files
    
    methods (Abstract)
        % save(dao, data, path) - exports data with the specified key
        % save(dao, data, results, path) - exports data and data analysis
        %                                 results with the specified key
        save(this, data, varargin);
        
        % data = load(dao, path) - imports data with the specified key
        % [data, results] = load(dao, path)- imports data and data analysis
        %                                    resuls with the specified key
        [data, results] = load(this, path)
        
        postfix = outputFilePostfix(this)
    end
    
    methods (Access=protected)
        function resultsFilePath = generateOutputDataFilePath(~, path)
        % generates a file path for accompanying results/output file for
        % formats that don't support additional data
            tok = regexp(path, '^(.+)\.([a-zA-Z]+)$', 'tokens');
            pathAndName = tok{1}{1};
            postfix = tok{1}{2};
            resultsFilePath = [pathAndName '_output.' postfix];
        end
    end
end

