classdef DataQueue < dao.IDataQueue
    % dao.DataQueue is a simple queue for loading data items on demand.
    % dao.DataQueue does not cache items, rather it manages a list of keys 
    % or ids, and loads the actual data using a dao.DataAccessor on demand.
    % 
    % Author - TADA, 2018
    
    properties
        DataLoader dao.IItemFetcher;
        Items;
        CurrentIndex;
        CurrentItem;
    end
    
    methods
        function this = DataQueue(dataLoader, list)
            this.DataLoader = dataLoader;

            if nargin < 2 || isempty(list)
                this.Items = {};
            elseif iscellstr(list) || isstring(list)
                this.Items = cellstr(list);
            else
                throw(MException('dao:DataQueue:InvalidListType', 'Items list must be a string array or a cell array of character vectors'));
            end

            this.CurrentIndex = 0;
            this.CurrentItem.index = 0;
            this.CurrentItem.item = [];
        end
        
        function tf = isPending(this)
        % Gets the current item from the queue without moving the queue
        % position.
        % 
        % tf = isPending(queue) - Determines whether there are items
        % pending in the queue
        % Output:
        %   tf - true if there are pending items, false otherwise
        % 
            tf = this.CurrentIndex <= numel(this.Items);
        end
        
        function [item, key] = peak(this)
        % Gets the current item from the queue without moving the queue
        % position.
        % 
        % [item, key] = peak(queue) - Gets the current item and its 
        % corresponding key from the queue.
        % Output:
        %   item - The item at the current position in the queue
        %   key  - The key of the item
        % 
            if isempty(this.CurrentIndex) || this.CurrentIndex == 0
                this.CurrentIndex = 1;
            end
            if ~this.isPending()
                item = [];
                key = [];
                return;
            end
            
            key = this.Items{this.CurrentIndex};
            if this.CurrentItem.index ~= this.CurrentIndex
                this.CurrentItem.index = this.CurrentIndex;
                this.CurrentItem.item = this.DataLoader.load(key);
            end
            item = this.CurrentItem.item;
        end
        
        function [item, key] = next(this)
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
        %
            if ~this.isPending()
                item = [];
                key = [];
                return;
            end
            this.CurrentIndex = this.CurrentIndex + 1;
            [item, key] = this.peak();
        end

        function [item, key] = previous(this)
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
        %
        
            if this.CurrentIndex < 2
                this.CurrentIndex = 1;
                item = [];
                key = [];
                return;
            end
            this.CurrentIndex = this.CurrentIndex - 1;
            [item, key] = this.peak();
        end
        
        function [item, key] = jumpTo(this, where)
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
        %
        
            if isnumeric(where) && where > 0 && where <= this.length()
                this.CurrentIndex = where;
                [item, key] = this.peak();
            elseif iscahr(where)
                this.currentIndex = find(strcmp({this.items.path}, where));
                [item, key] = this.peak();
            else
                error('Huh? specified data item identifier should be either string name or index.');
            end
        end
        
        function names = getDataNameList(this)
            names = {this.Items.path};
        end
        
        function len = length(this)
            len = numel(this.Items);
        end
        
        function n = itemsLeft(this)
            n = this.length() - this.CurrentIndex;
        end

        function [done, left] = progress(this)
            done = this.CurrentIndex;
            left = this.itemsLeft();
        end
    end
end

