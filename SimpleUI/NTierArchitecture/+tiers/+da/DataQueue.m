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
            if ~isa(dataLoader, 'Simple.DataAccess.DataAccessor')
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
            if ~this.isPending()
                item = [];
                return;
            end
            this.currentIndex = this.currentIndex + 1;
            [item, key] = this.peak();
        end

        function [item, key] = previous(this)
            if this.currentIndex < 2
                item = [];
                return;
            end
            this.currentIndex = this.currentIndex - 1;
            [item, key] = this.peak();
        end
        
        function [item, key] = jumpTo(this, where)
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

