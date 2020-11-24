classdef (Abstract) FileSystemDataAccessor < dao.DataAccessor & mxml.IMXmlIgnoreFields
% FileSystemDataAccessor is a base class for implementations of the
% dao.DataAccessor batch data access object for whom the data is saved as
% files on a file system

    properties
        ErrorHandler mvvm.IErrorHandler = mvvm.App.empty();
        QueueFactory dao.IQueueFactory = dao.SimpleDataQueueFactory.empty();
        BatchPath;
        Exporter dao.FSOutputDataExporter = dao.MXmlDataExporter.empty();
        StartTime;
        ProcessedResultsPath;
        ErrorLogPath;
        SaveAcceptedItems (1,1) logical = true;
    end
    
    methods %Property getters/setters
        
        function value = get.ProcessedResultsPath(this)
            if ~isempty(this.ProcessedResultsPath)
                value = this.ProcessedResultsPath;
                return;
            end
            
            value = dao.processOutputIOPath(fullfile(this.BatchPath, 'processed_{timestamp}'), this.StartTime);
        end
        function set.ProcessedResultsPath(this, value)
            this.ProcessedResultsPath = value;
        end
        
        function value = get.ErrorLogPath(this)
            if ~isempty(this.ErrorLogPath)
                value = this.ErrorLogPath;
                return;
            end
            
            value = dao.processOutputIOPath(fullfile(this.BatchPath, 'errors_{timestamp}'), this.StartTime);
        end
        function set.ErrorLogPath(this, value)
            this.ErrorLogPath = value;
        end
    end
    
    methods % Ctors
        function this = FileSystemDataAccessor(errorHandler, exporter, queueFactory)
            this = this@dao.DataAccessor();
            this.ErrorHandler = errorHandler;
            this.StartTime = now;
            this.Exporter = exporter;
            
            if nargin >= 3 && ~isempty(queueFactory)
                this.QueueFactory = queueFactory;
            else
                this.QueueFactory = dao.SimpleDataQueueFactory(this);
            end
        end
    end

    methods
        function queue = loadQueue(this, batchPath)
            if nargin >= 2 && ~isempty(batchPath)
                this.BatchPath = batchPath;
            end
            
            try
                postFixFilter = cellstr(this.fileTypeFilter());
                files = gen.dirfiles(this.BatchPath, postFixFilter{:});
            catch ex
                this.logError([], ex);
                queue = dao.DataQueue.empty();
                return;
            end
            filesNames = {files.name};
            queue = this.QueueFactory.build(filesNames);
        end
        
        function filter = fileTypeFilter(this)
            % Override in derived class to filter only desired file types
            % (xml, csv, tsv, txt, etc.)
            filter = '*.*';
        end
        
        function acceptData(this, key)
            if ~this.SaveAcceptedItems
                return;
            end
            
            try
                destinationFile = fullfile(this.ProcessedResultsPath, key);
                
                % make sure output folder exists
                dao.ensureFolder(this.ProcessedResultsPath);

                if ~exist(destinationFile, 'file')
                    [status, msg] = copyfile(fullfile(this.BatchPath, key), destinationFile, 'f');
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
                destinationFile = fullfile(this.ProcessedResultsPath, key);
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
                    destinationFile = fullfile(this.ErrorLogPath, key);
                    
                    % make sure error log folder exists
                    dao.ensureFolder(this.ErrorLogPath);

                    if ~exist(destinationFile, 'file')
                        [status, msg] = copyfile(fullfile(this.BatchPath, key), destinationFile, 'f');
                        if ~status
                            this.logError('', msg);
                        end
                    end 
                catch ex
                    this.logError('', ex);
                end
            end
            this.ErrorHandler.handleException(['something went wrong while analizing curve ' key], err, this.ErrorLogPath, dao.processOutputIOPath('error_{timestamp}.log'));
        end

        % Saves the processed data results of a data analysis process
        function saveResults(this, data, output)
            path = fullfile(this.ProcessedResultsPath, 'output', ['results.' this.Exporter.outputFilePostfix()]);
            if nargin < 3
                this.Exporter.save(data, path);
            else
                this.Exporter.save(data, output, path);
            end
        end
        
        % Import previously processed data results
        function [data, results] = importResults(this, importDetails)
            [data, results] = this.Exporter.load(importDetails.path);
        end
        
        function b = equals(this, other)
            b = equals@dao.DataAccessor(this, other);
            b = b && strcmp(this.BatchPath, other.BatchPath);
        end
    end
    
    methods (Hidden)
        function ignoreList = getMXmlIgnoreFieldsList(~)
            ignoreList = {'QueueFactory', 'ErrorHandler'};
        end
    end
end

