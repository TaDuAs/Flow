classdef (Abstract) FileSystemDataAccessor < Simple.DataAccess.DataAccessor
    properties
        app;
        batchPath;
        exporter;
        startTime;
        processedResultsPath;
        errorLogPath;
    end
    
    methods %Property getters/setters
        
        function value = get.processedResultsPath(this)
            if ~isempty(this.processedResultsPath)
                value = this.processedResultsPath;
                return;
            end
            
            value = Simple.DataAccess.processOutputIOPath(fullfile(this.batchPath, 'processed_{timestamp}'), this.startTime);
        end
        function set.processedResultsPath(this, value)
            this.processedResultsPath = value;
        end
        
        function value = get.errorLogPath(this)
            if ~isempty(this.errorLogPath)
                value = this.errorLogPath;
                return;
            end
            
            value = Simple.DataAccess.processOutputIOPath(fullfile(this.batchPath, 'errors_{timestamp}'), this.startTime);
        end
        function set.errorLogPath(this, value)
            this.errorLogPath = value;
        end
    end
    
    methods % Ctors
        function this = FileSystemDataAccessor(app, exporter, batchPath, processedResultsPath, errorLogPath)
            Simple.obsoleteWarning('Simple.DataAccess');
            if (nargin < 3 || isempty(processedResultsPath)); processedResultsPath = []; end
            if (nargin < 4 || isempty(errorLogPath)); errorLogPath = []; end

            this = this@Simple.DataAccess.DataAccessor();
            this.app = app;
            this.batchPath = batchPath;
            this.startTime = now;
            this.processedResultsPath = processedResultsPath;
            this.errorLogPath = errorLogPath;

            if ~isa(exporter, 'Simple.DataAccess.FSOutputDataExporter')
                error('Must specify a valid FSOutputDataExporter to save output results');
            end
            this.exporter = exporter;
        end
    end

    methods
        function queue = loadQueue(this)
            try
                files = dir(fullfile(this.batchPath, this.fileTypeFilter()));
            catch ex
                this.logError([], ex);
                queue = [];
                return;
            end
            files = {files.name};
            queue = Simple.DataAccess.DataQueue(this, files);
        end
        
        function filter = fileTypeFilter(this)
            % Override in derived class to filter only desired file types
            % (xml, csv, tsv, txt, etc.)
            filter = '*.*';
        end
        
        function acceptData(this, key)
            try
                destinationFile = fullfile(this.processedResultsPath, key);
                
                % make sure output folder exists
                Simple.DataAccess.ensureFolder(this.processedResultsPath);

                if ~exist(destinationFile, 'file')
                    [status, msg] = copyfile(fullfile(this.batchPath, key), destinationFile, 'f');
                    if ~status
                        this.logError(key, msg);
                    end
                end
            catch ex
                this.logError(key, ex);
            end
        end
        
        function rejectData(this, key)
            % if was previously accepted, undo that
            try
                destinationFile = fullfile(this.processedResultsPath, key);
                if exist(destinationFile, 'file')
                    delete(destinationFile);
                end
            catch ex
                this.logError(key, ex);
            end
        end
        
        function revertDecision(this, key)
            % if was previously accepted, undo that
            this.rejectData(key);
        end

        function logError(this, key, err)
            if ~isempty(key)
                try
                    destinationFile = fullfile(this.errorLogPath, key);
                    
                    % make sure error log folder exists
                    Simple.DataAccess.ensureFolder(this.errorLogPath);

                    if ~exist(destinationFile, 'file')
                        [status, msg] = copyfile(fullfile(this.batchPath, key), destinationFile, 'f');
                        if ~status
                            this.logError('', msg);
                        end
                    end 
                catch ex
                    this.logError('', ex);
                end
            end
            this.app.handleException(['something went wrong while analizing curve ' key], err, this.errorLogPath, Simple.DataAccess.processOutputIOPath('error_{timestamp}.log'));
        end

        % Saves the processed data results of a data analysis process
        function saveResults(this, data, output)
            path = fullfile(this.processedResultsPath, 'output', ['results.' this.exporter.outputFilePostfix()]);
            if nargin < 3
                this.exporter.save(data, path);
            else
                this.exporter.save(data, output, path);
            end
        end
        
        % Import previously processed data results
        function data = importResults(this, importDetails)
            data = this.exporter.load(importDetails.path);
        end
        
        function b = equals(this, other)
            b = equals@Simple.DataAccess.DataAccessor(this, other);
            b = b && strcmp(this.batchPath, other.batchPath);
        end
    end
end

