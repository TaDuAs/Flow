classdef TableDataExporter < dao.DelimiterValuesDataExporter
    methods
        function this = TableDataExporter(delimiter)
            if nargin < 1; delimiter = []; end
            this@dao.DelimiterValuesDataExporter(delimiter)
        end
        
        function save(this, data, output, path)
            if ~istable(data)
                throw(MException('dao:TableDataExporter:InvalidDataType', 'dao.TableDataExporter only supports tables'));
            end
            
            dao.ensureFolder(fileparts(path));
            writetable(data, path, 'Delimiter', this.delimiter);
            if ~isempty(output)
                this.save(output, this.generateOutputDataFilePath(path));
            end
        end
        
        function [data, output] = load(this, path)
            tok = regexp(path, '\.([a-zA-Z]+)$', 'tokens');
            if isempty(tok)
                fileDelimiter = this.delimiter;
            else
                fileDelimiter = this.delimiterFromPostfix(string(tok{1}));
            end
            
            data = readtable(path, 'Delimiter', fileDelimiter);
            if nargout >= 2
                output = this.load(this.generateOutputDataFilePath(path));
            end
        end
        
    end
end

