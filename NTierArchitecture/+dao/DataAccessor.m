classdef (Abstract) DataAccessor < handle & dao.IItemFetcher
% DataAccessor is a data access object (dao) for batch processes - it
% supports sequential batch processing by generating a dao.IDataQueue which
% loads entities from the data layer in an ordered fashion
    
    methods (Abstract)
        % Loads a batch of data items in the form of a dao.DataQueue
        queue = loadQueue(this)
        
        % Accept data item - it passed processing
        acceptData(this, key)
        
        % Reject data item - it doesn't pass processing
        rejectData(this, key)

        % Reverts any previously made decisions regarding a data item
        revertDecision(this, key)

        % Logs an error in the processing of a data item
        logError(this, key, err)

        % Saves the processed data results of a data analysis process
        saveResults(this, data, output)
        
        % Import previously processed data results
        [data, results] = importResults(this, importDetails)
    end
    
    methods
        function b = equals(this, other)
            b = strcmp(class(this), class(other));
        end
    end
end

