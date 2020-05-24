classdef MXmlDataAccessor < dao.FileSystemDataAccessor
    properties
        Serializer mxml.ISerializer = mxml.XmlSerializer.empty();
    end
    
    methods
        function this = MXmlDataAccessor(exporter, batchPath, processedResultsPath, errorLogPath)
            if (nargin < 3); processedResultsPath = []; end
            if (nargin < 4); errorLogPath = []; end
            
            this = this@dao.FileSystemDataAccessor(exporter, batchPath, processedResultsPath, errorLogPath);
        end

        function item = load(this, fileName)
            item = this.Serializer.load(fullfile(this.batchPath, fileName));
        end
        
        function filter = fileTypeFilter(this)
            filter = '*.xml';
        end
    end
end
