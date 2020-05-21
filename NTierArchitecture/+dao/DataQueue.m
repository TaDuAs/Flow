classdef DataQueue < handle
    %DATAQUEUE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataLoader;
        list;
        currentIndex;
        currentItem;
    end
    
    methods
        function this = DataQueue(dataLoader, list)
            if ~isa(dataLoader, 'dao.DataAccessor')
                error('Must specify a valid DataLoader')
            end
            this.dataLoader = dataLoader;

            if nargin < 2 || isempty(list)
                this.list = Simple.List(1000, struct('path',{}));
            elseif isa(list, 'Simple.List')
                this.list = list;
            elseif iscellstr(list)
                this.list = Simple.List(struct('path', list), length(list), struct('path',''));
            end

            this.currentIndex = 0;
            this.currentItem.index = 0;
            this.currentItem.item = [];
        end
        
        function bool = isPending(this)
            bool = this.currentIndex <= length(this.list);
        end
        
        function [item, key] = peak(this)
            if isempty(this.currentIndex) || this.currentIndex == 0
                this.currentIndex = 1;
            end
            if ~this.isPending()
                item = [];
                key = [];
                return;
            end
            
            currentItemFromList = this.list.get(this.currentIndex);
            key = currentItemFromList.path;
            if this.currentItem.index ~= this.currentIndex
                this.currentItem.index = this.currentIndex;
                this.currentItem.item = this.dataLoader.load(key);
            end
            item = this.currentItem.item;
        end
        
        function [item, key] = next(this)
        % next - Changes the current location of the queue to the next
        % position. If the current location is at the 9th item, then next
        % will change it to the 10th position. next also returns the item 
        % and key at the new position.
        %
        % [item, key] = jumpTo(i) - moves to the i'th item in the queue
        % Input:
        %   i - An integer scalar representing the the numeric index of the
        %       desired item in the queue
        % Output:
        %   item - The item at the i'th index
        %   key  - The key identifier of the item in the i'th index
        %
        % [item, key] = jumpTo(key) - moves the current queue location to 
        %   the item with the specified key
        % Input:
        %   key - The key identifier of the desired item
        % Output:
        %   item - The item corresponding to the specified key
        %   key  - The key
        %
            if ~this.isPending()
                item = [];
                return;
            end
            this.currentIndex = this.currentIndex + 1;
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
        
            if this.currentIndex < 2
                this.currentIndex = 1;
                item = [];
                key = [];
                return;
            end
            this.currentIndex = this.currentIndex - 1;
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
                this.currentIndex = where;
                [item, key] = this.peak();
            elseif iscahr(where)
                this.currentIndex = find(strcmp({this.list.vector.path}, where));
                [item, key] = this.peak();
            else
                error('Huh? specified data item identifier should be either string name or index.');
            end
        end
        
        function names = getDataNameList(this)
            names = {this.list.vector().path};
        end
        
        function len = length(this)
            len = length(this.list);
        end
        
        function n = itemsLeft(this)
            n = this.length() - this.currentIndex;
        end

        function [done, left] = progress(this)
            done = this.currentIndex;
            left = this.itemsLeft();
        end
    end
end

