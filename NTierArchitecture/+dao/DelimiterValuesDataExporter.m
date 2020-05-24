classdef DelimiterValuesDataExporter < dao.FSOutputDataExporter
    properties
        delimiter = ',';
    end
    
    methods
        function this = DelimiterValuesDataExporter(delimiter)
            if nargin >= 1 && ischar(delimiter) && ~isempty(delimiter)
                this.validateDelimiter(delimiter);
                this.delimiter = delimiter;
            end
        end
        
        function save(this, data, output, path)
            properties = fields(data);
            t = table();
            for i = 1:length(properties)
                % I know i should preallocate, maybe someday, or maybe i'll
                % build a struct then use struct2table or somethoing
                t = [t table({data.(properties{i})}', 'VariableNames', properties(i))];
            end
            
            dao.ensureFolder(fileparts(path));
            writetable(t, path, 'Delimiter', this.delimiter);
            if ~isempty(output)
                this.save(output, this.generateOutputDataFilePath(path));
            end
        end
        
        function [data, output] = load(this, path)
            tok = regexp(path, '\.([a-zA-Z]+)$', 'tokens');
            if isempty(tok)
                fileDelimiter = this.delimiter;
            else
                fileDelimiter = this.delimiterFromPostfix(tok{1});
            end
            
            M = tdfread(path, fileDelimiter);
            data = structofarrays2arrayofstructs(M);
            if nargout >= 2
                output = this.load(this.generateOutputDataFilePath(path));
            end
        end
        
        function postfix = outputFilePostfix(this)
            switch this.delimiter
                case ','; postfix = 'csv';
                case 'comma'; postfix = 'csv';
                case '\t'; postfix = 'tsv';
                case 'tab'; postfix = 'tsv';
                case ' '; postfix = 'ssv';
                case 'space'; postfix = 'ssv';
                case ';'; postfix = 'smsv';
                case 'semi'; postfix = 'smsv';
                case '|'; postfix = 'bsv';
                case 'bar'; postfix = 'bsv';
            end
        end
        
    end
    
    methods (Access=private)
        function validateDelimiter(this, delimiter)
            switch delimiter
                case ','; return;
                case 'comma'; return;
                case '\t'; return;
                case 'tab'; return;
                case ' '; return;
                case 'space'; return;
                case ';'; return;
                case 'semi'; return;
                case '|'; return;
                case 'bar'; return;
            end
            
            error('Delimiter for separated values files should be one of: '','', ''comma'', ''\t'', ''tab'', '';'', ''semi'', '' '', ''space'', ''|'', ''bar''.');
        end
        
        function fileDelimiter = delimiterFromPostfix(this, postfix)
            switch postfix
                case 'csv'
                    fileDelimiter = ',';
                case 'tsv'
                    fileDelimiter = '\t';
                case 'bsv'
                    fileDelimiter = '|';
                case 'ssv'
                    fileDelimiter = ' ';
                case 'smsv'
                    fileDelimiter = ';';
                otherwise
                    fileDelimiter = this.delimiter;
            end
        end
    end
end

