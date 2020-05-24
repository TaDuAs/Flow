classdef (Abstract) IDataQueue < handle
    % dao.DataQueue is an interface class for data queues in context of 
    % data access layer.
    % 
    % Author - TADA, 2020
    
    methods (Abstract)
        % Gets the current item from the queue without moving the queue
        % position.
        % 
        % tf = isPending(queue) - Determines whether there are items
        % pending in the queue
        % Output:
        %   tf - true if there are pending items, false otherwise
        tf = isPending(this);
        
        % Gets the current item from the queue without moving the queue
        % position.
        % 
        % [item, key] = peak(queue) - Gets the current item and its 
        % corresponding key from the queue.
        % Output:
        %   item - The item at the current position in the queue
        %   key  - The key of the item
        [item, key] = peak(this);
        
        % next - Changes the current location of the queue to the next
        % position. If the current location is at the 9th item, then next
        % will change it to the 10th position. next also returns the item 
        % and key at the new position. If there are no pending items in the
        % queue, returns empty item and key.
        %
        % [item, key] = next(queue) - moves to the i'th item in the queue
        % Output:
        %   item - The item at the new position in the queue
        %   key  - The key of the item
        [item, key] = next(this);
        
        % previous - Changes the current location of the queue to the
        % previous position. If the current location is at the 10th item,
        % then previous will change it to the 9th position. previous also
        % returns the item and key at the new position. When there is no
        % previous position, the queue returns an empty item and key.
        %
        % [item, key] = previous(queue) - moves to the previous position
        % Output:
        %   item - The item at the new position
        %   key  - The key identifier of the item
        [item, key] = previous(this);
        
        % jumpTo - Changes the current location of the queue to a specifie
        % item, and returns the item and its key.
        %
        % [item, key] = jumpTo(queue, i) - moves to the i'th item in the queue
        % Input:
        %   i - An integer scalar representing the the numeric index of the
        %       desired item in the queue
        % Output:
        %   item - The item at the i'th index
        %   key  - The key identifier of the item in the i'th index
        %
        % [item, key] = jumpTo(queue, key) - moves the current queue location to 
        %   the item with the specified key
        % Input:
        %   key - The key identifier of the desired item
        % Output:
        %   item - The item corresponding to the specified key
        %   key  - The key
        [item, key] = jumpTo(this, where);
        
        % getDataNameList returns a list of keys/identifiers of all items
        % in the queue
        names = getDataNameList(this);
        
        % length returns the length of the entire queue
        l = length(this);
        
        % itemsLeft returns the number of pending items in the queue
        n = itemsLeft(this);
        
        % progress returns a queue progress report
        % Output:
        %   done - number of items already processed from the queue
        %   left - number of pending items in the queue
        [done, left] = progress(this);
    end
end

