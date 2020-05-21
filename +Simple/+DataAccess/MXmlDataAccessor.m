classdef MXmlDataAccessor < Simple.DataAccess.FileSystemDataAccessor
    methods
        function this = MXmlDataAccessor(exporter, batchPath, processedResultsPath, errorLogPath)
            Simple.obsoleteWarning('Simple.DataAccess');
            if (nargin < 3); processedResultsPath = []; end
            if (nargin < 4); errorLogPath = []; end
            
            this = this@Simple.DataAccess.FileSystemDataAccessor(exporter, batchPath, processedResultsPath, errorLogPath);
        end

        function item = load(this, fileName)
            item = Simple.IO.MXML.load(fullfile(this.batchPath, fileName));
        end
        
        function filter = fileTypeFilter(this)
            filter = '*.xml';
        end
    end
end
