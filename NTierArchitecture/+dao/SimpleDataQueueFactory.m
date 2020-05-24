classdef SimpleDataQueueFactory < dao.IQueueFactory
    methods
        % Builds a data queue using input
        function queue = build(~, keys)
            queue = dao.DataQueue(keys);
        end
    end
end

