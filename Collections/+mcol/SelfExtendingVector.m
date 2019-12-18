classdef (Abstract) SelfExtendingVector < handle
    %SELFEXTENDINGLIST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        LastIndex = 0;
        EmptyCells;
        EmptyCellValue;
        ArrayPropName;
        Growth {mustBeMember(Growth, {'exp', 'lin'})} = 'lin';
        GrowthFactor;
        GrowthDimension = 2;
    end
    
    methods (Access=protected)
        function this = SelfExtendingVector(arrayPropName, emptyCellValue, growthFactor, growthType, growthDim)
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
            
            if nargin >= 5
                this.GrowthDimension = growthDim;
            end
        end
        
        function add(this, value)
            addAt = (1:size(value, this.GrowthDimension)) + this.LastIndex;
            this.setv(addAt, value);
        end
        
        function setv(this, i, value)
            % ensure the vector can accomodate the new data and stretch it
            % if its too small
            this.ensureListSize(numel(i));
            
            % prepare indexing for setting new data
            idx = repmat({':'}, 1, max(2, this.GrowthDimension));
            idx{this.GrowthDimension} = i;
            
            % set new data
            this.(this.ArrayPropName)(idx{:}) = value;
            
            % 
            this.LastIndex = max(this.LastIndex, i(end));
        end
        
        function removeItemAt(this, i)
        end
    end
    
    methods (Access=private)
        function stub = generateStub(this, stubLength)
            if nargin < 2 || isempty(stubLength) || stubLength < 1
                stubLength = this.typicalSize;
            end
        end
        
        function this = ensureListSize(this, neededSize)
            arr = this.(this.ArrayPropName);
            actualArrSize = numel(arr);
            freeSize = numel(arr) - this.LastIndex;
            growthFactor = this.typicalSize;
            
            if neededSize > freeSize
                if strcmp(this.Growth, 'exp')
                    extendByThisMuch = max(actualArrSize*(growthFactor-1), (neededSize-actualArrSize)*growthFactor);
                else
                    extendByThisMuch = neededSize - freeSize + growthFactor;
                end
                
                % generate a stub to extend the list
                replicationScheme = ones(1, max(2, this.GrowthDimension));
                replicationScheme(this.GrowthDimension) = stubLength;
                stub = repmat(this.EmptyCellValue, replicationScheme);
                
                % concat stub to list
                this.(this.ArrayPropName) = cat(this.GrowthDimension, arr, stub);
                
                % extend the empty cells index as well
                % here it is in fact easier to use false to generate the
                % logical index for a single empty item, then to repeat
                % that using the replication scheme we already created for
                % generating the stub
                indexStub = repmat(false(size(this.EmptyCellValue)), replicationScheme);
                this.EmptyCells = cat(this.GrowthDimension, this.EmptyCells, indexStub);
            end
        end
    end
end

