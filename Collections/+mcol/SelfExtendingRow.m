classdef (Abstract) SelfExtendingRow < handle
    %SELFEXTENDINGLIST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        LastIndex = 0;
        EmptyCellValue;
        ArrayPropName;
        Growth {mustBeMember(Growth, {'exp', 'lin'})} = 'lin';
        GrowthFactor;
    end
    
    methods
        function this = SelfExtendingRow(arrayPropName, emptyCellValue, growthFactor, growthType)
            this.ArrayPropName = arrayPropName;
            this.EmptyCellValue = emptyCellValue;
            
            if nargin >= 4
                this.Growth = growthType;
            end
            
            if nargin >= 3
                this.GrowthFactor = growthFactor;
            elseif strcmp(this.Growth, 'exp')
                this.GrowthFactor = 2;
            else
                this.GrowthFactor = 100;
            end
        end
        
        function tf = any(this, condition)
            arr = this.(this.ArrayPropName);
            tf = any(condition(arr(1:this.LastIndex)));
        end
        
        function n = length(this)
            n = this.LastIndex;
        end
        
        function varargout = size(this, dim)
            varargout = cell(max(nargout, 1));
            
            if nargin > 1
                varargout{:} = size(this.list, dim);
            else
                varargout{:} = size(this.list);
            end
        end

        function tf = isempty(this)
            tf = this.LastIndex == 0;
        end
        
        function add(this, value)
            addAt = (1:size(value, 2)) + this.LastIndex;
            this.setv(addAt, value);
        end
        
        function setv(this, i, value)
            logicalIdx = islogical(i);
            numericIdx = isnumeric(i);
            
            % ensure the vector can accomodate the new data and stretch it
            % if its too small
            if logicalIdx
                necessarySize = size(i, 2);
            elseif numericIdx
                necessarySize = max(i);
            elseif strcmp(i, ':')
                necessarySize = this.LastIndex;
            else
                throw(MException('mcol:SelfExtendingRow:InvalidIndexing', 'invalid indexing operation'));
            end
            
            % stretch allocated vector if necessary
            this.ensureListSize(necessarySize);
                        
            % set new data
            this.(this.ArrayPropName)(:,i) = value;
            
            % update the last index if necessary
            if logicalIdx
                this.LastIndex = max(this.LastIndex, size(i, 2));
            elseif numericIdx
                this.LastIndex = max(this.LastIndex, max(i));
            end
            % for indexing of the entire array its not necessary to update
            % the last index
        end
        
        function removeAt(this, i)
            % for simplicities sake, removal reallocates the vector
            logicalIdx = islogical(i);
            numericIdx = isnumeric(i);
            
            % ensure the vector can accomodate the new data and stretch it
            % if its too small
            if logicalIdx
                necessarySize = size(i, 2);
            elseif numericIdx
                this.removeAtNumericIndex(i);
            elseif strcmp(i, ':')
                % remove everything
                this.LastIndex = 0;
                this.(this.ArrayPropName)(:,:) = repmat(this.EmptyCellValue, 1, size(this.(this.ArrayPropName), 2));
                return;
            else
                throw(MException('mcol:SelfExtendingRow:InvalidIndexing', 'invalid indexing operation'));
            end
        end
    end
    
    methods (Access=private)
        function removeAtNumericIndex(this, i)
            % this operation will move all indices to the left, starting 
            % the first removed index.
            idx = i(:);
            minIdx = min(idx);
            arr = this.(this.ArrayPropName);
            n = size(arr, 2);
            lastIndex = this.LastIndex;
            nRemovedIndices = numel(idx);
            
            % use logical indexing to extract all moved indices
            movedIndices = [false(1, minIdx - 1), true(1, lastIndex - minIdx + 1), false(1, n - lastIndex)];
            
            % don't extract the removed elements
            movedIndices(idx) = false;
            
            % use logical indexing to shift extracted elements to the left
            assignedIndices = [false(1, minIdx - 1), true(1, lastIndex - nRemovedIndices - minIdx + 1), false(1, n - lastIndex + nRemovedIndices)];
            
            % shift elements, overriding the extracted ones
            this.(this.ArrayPropName)(:, assignedIndices) = arr(:, movedIndices);
            
            % overwrite removed elements with empty-cell-value to allow for
            % garbage collection. while this is unnecessary for primitive
            % types, it could be crucial when working with object/struct 
            % arrays
            this.(this.ArrayPropName)(:, lastIndex + 1 - nRemovedIndices) = repmat(this.EmptyCellValue, 1, nRemovedIndices);
            
            % update the last index
            this.LastIndex = lastIndex - nRemovedIndices;
        end
        
        function this = ensureListSize(this, neededSize)
            arr = this.(this.ArrayPropName);
            actualArrSize = numel(arr);
            freeSize = numel(arr) - this.LastIndex;
            growthFactor = this.GrowthFactor;
            
            if neededSize > freeSize
                if strcmp(this.Growth, 'exp')
                    extendByThisMuch = max(actualArrSize*(growthFactor-1), (neededSize-actualArrSize)*growthFactor);
                else
                    extendByThisMuch = neededSize - freeSize + growthFactor;
                end
                
                % generate a stub to extend the list
                stub = repmat(this.EmptyCellValue, 1, extendByThisMuch);
                
                % concat stub to list
                this.(this.ArrayPropName) = horzcat(arr, stub);
            end
        end
    end
end

