classdef MXmlDataExporter < Simple.DataAccess.FSOutputDataExporter
    methods
        function save(this, data, a, b)
            if nargin == 3
                path = a;
                output = [];
            else
                path = b;
                output = a;
            end
            Simple.IO.MXML.save(path, data, output);
        end
        
        function [data, output] = load(this, path)
            [data, output] = Simple.IO.MXML.load(path, this.outputFilePostfix());
        end
        
        function postfix = outputFilePostfix(this)
            postfix = 'xml';
        end
    end
    
end

