classdef SimpleDataQueueFactory < dao.IQueueFactory
    
    properties
        DAO dao.DataAccessor = dao.MXmlDataAccessor.empty();
    end
    
    methods
        
        function this = SimpleDataQueueFactory(daObj)
            this.DAO = daObj;
        end
        
        % Builds a data queue using input
        function queue = build(this, keys)
            queue = dao.DataQueue(this.DAO, keys);
        end
    end
end

