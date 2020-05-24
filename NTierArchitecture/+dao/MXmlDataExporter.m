classdef MXmlDataExporter < dao.FSOutputDataExporter
    properties
        Serializer mxml.ISerializer = mxml.XmlSerializer.empty();
    end
    
    methods
        function save(this, data, path)
            this.Serializer.save(data, path);
        end
        
        function data = load(this, path)
            data = this.Serializer.load(path);
        end
        
        function postfix = outputFilePostfix(this)
            postfix = 'xml';
        end
    end
    
end

