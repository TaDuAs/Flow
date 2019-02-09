classdef ObservableArray < mvvm.collections.ICollection
    %OBSERVABLECELL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Array;
        IndexingMethod;
    end
    
    methods % property accessors
        function set.IndexingMethod(this, value)
            this.validateIndexingMethod(value);
            this.IndexingMethod = value;
        end
    end
    
    methods % mvvm.collections.ICollection
        function b = containsIndex(this, varargin)
            if nargin > 2
                i = varargin;
            else
                i = varargin{1};
            end
            
            % handle multidimentional subs
            if iscell(i)
                % assume index exists
                b = true(cellfun(@numel, i));

                % go through all dimentions in the specified subs indexing
                for j = 1:numel(i)
                    currIdx = i{j}; 
                    
                    % colon indexing A(:) must exist because it's all
                    % indinces in that given dimention
                    if ischar(currIdx) && strcmp(currIdx, ':')
                        continue;
                    end
                    
                    % check all indices in current dimention
                    currDim = ones(1, numel(i));
                    currDim(j) = numel(currIdx);
                    dimIdxVector = reshape(currIdx <= size(this.Array, j), currDim);
                    
                    % repeat curr dimention vector for all specified
                    % dimentions and add condition to contains matrix (b)
                    otherDims = cellfun('length', i);
                    otherDims(j) = 1;
                    b = b & repmat(dimIdxVector, otherDims);
                end
            else
                switch (this.IndexingMethod)
                    case 'cells'
                        b = i <= numel(this.Array);
                    case 'rows'
                        b = i <= size(this.Array, 1);
                    case 'cols'
                        b = i <= size(this.Array, 2);
                end
            end
        end
        
        function n = length(this)
            switch (this.IndexingMethod)
                case 'cells'
                    n = numel(this.Array);
                case 'rows'
                    n = size(this.Array, 1);
                case 'cols'
                    n = size(this.Array, 2);
            end
        end
        
        function b = isempty(this)
            b = isempty(this.Array);
        end
        
        function s = size(this, dim)
            if nargin > 1
                s = size(this.Array, dim);
            else
                s = size(this.Array);
            end
        end
        
        function value = getv(this, varargin)
            if nargin > 2
                i = varargin;
            else
                i = varargin{1};
            end
            
            if iscell(i)
                if iscell(this.Array) && all(cellfun('length', i) == 1) && all(cellfun(@(c) ~strcmp(c,':'), i))
                    value = this.Array{i{:}};
                else
                    value = this.Array(i{:});
                end
            else
                switch (this.IndexingMethod)
                    case 'cells'
                        if iscell(this.Array) && numel(i) == 1
                            value = this.Array{i};
                        else
                            value = this.Array(i);
                        end
                    case 'rows'
                        value = this.Array(i, :);
                    case 'cols'
                        value = this.Array(:, i);
                end
            end
        end
        
        function setv(this, value, varargin)
            if nargin > 3
                i = varargin;
            else
                i = varargin{1};
            end
            
            if iscell(i)
                if iscell(this.Array) && all(cellfun('length', i) == 1) && all(cellfun(@(c) ~strcmp(c,':'), i))
                    this{i{:}} = value;
                else
                    this(i{:}) = value;
                end
            else
                switch (this.IndexingMethod)
                    case 'cells'
                        if iscell(this.Array) && numel(i) == 1
                            this{i} = value;
                        else
                            this(i) = value;
                        end
                    case 'rows'
                        this(i, :) = value;
                    case 'cols'
                        this(:, i) = value;
                end
            end
        end
        
        function removeAt(this, varargin)
            if nargin > 2
                i = varargin;
            else
                i = varargin{1};
            end
            
            if iscell(i)
                this.Array(i{:}) = [];
                indexingMethodIndices = this.convertSubsCellToIndexingMethodIndices(i);
            else
                indexingMethodIndices = i;
                switch (this.IndexingMethod)
                    case 'cells'
                        this.Array(i) = [];
                    case 'rows'
                        this.Array(i, :) = [];
                    case 'cols'
                        this.Array(:, i) = [];
                end
            end
            
            arg = mvvm.collections.CollectionChangedEventData('remove', indexingMethodIndices, i);
            this.notify('collectionChanged', arg);
        end
        
        function keySet = keys(this)
            switch (this.IndexingMethod)
                case 'cells'
                    keySet = 1:numel(this.Array);
                case 'rows'
                    keySet = 1:size(this.Array, 1);
                case 'cols'
                    keySet = 1:size(this.Array, 2);
            end
        end
    end
    
    methods % indexing
        function B = subsref(A, S)
            if any(strcmp(S(1).type, {'()', '{}'}))
                B = subsref(A.Array, S);
            else
                B = builtin('subsref', A, S);
            end
        end
        
        function A = subsasgn(A, S, B)
            if any(strcmp(S(1).type, {'()', '{}'}))
                idx = S(1).subs;
                hasEventListeners = event.hasListener(A, 'collectionChanged'); 
                
                % if has event listeners check indices before assignment to
                % compare after assignment
                if hasEventListeners
                    hadIndexBefore = A.containsIndex(idx);
                end
                
                A.Array = subsasgn(A.Array, S, B);
                
                % if has event listeners check indices after assignment and
                % raise events
                if hasEventListeners
                    hasIndexAfter =  A.containsIndex(idx);

                    % notify removed
                    removedIdx = ~hasIndexAfter & hadIndexBefore;
                    if any(removedIdx)
                        isubs = A.getAvailableIndices(idx, removedIdx);
                        indexMethodIdx = this.convertSubsCellToIndexingMethodIndices(isubs);
                        A.notify('collectionChanged', mvvm.collections.CollectionChangedEventData('remove', indexMethodIdx, isubs));
                    end

                    % notify added
                    addedIdx = hasIndexAfter & ~hadIndexBefore;
                    if any(addedIdx)
                        isubs = A.getAvailableIndices(idx, addedIdx);
                        indexMethodIdx = this.convertSubsCellToIndexingMethodIndices(isubs);
                        A.notify('collectionChanged', mvvm.collections.CollectionChangedEventData('add', indexMethodIdx, isubs));
                    end

                    % notify changed
                    changedIdx = hasIndexAfter & hadIndexBefore;
                    if any(changeIdx)
                        isubs = A.getAvailableIndices(idx, changedIdx);
                        indexMethodIdx = this.convertSubsCellToIndexingMethodIndices(isubs);
                        A.notify('collectionChanged', mvvm.collections.CollectionChangedEventData('change', indexMethodIdx, isubs));
                    end
                end
            else
                A = builtin('subsasgn', A, S, B);
            end
        end
    end
    
    methods
        function this = ObservableArray(varargin)
            if mod(nargin, 2) == 1
                this.Array = varargin{1};
                this.parseConfiguration(varargin{2:end});
            else
                this.Array = [];
                this.parseConfiguration(varargin{:});
            end
        end
    end
    
    methods (Access=protected)
        function i = convertSubsCellToIndexingMethodIndices(this, subs)
            % generate a logical index of this array, set it all to 0
            indFlags = false(size(this.Array));
            
            % change the logical array elements to 1 at the specified subs
            indFlags(subs{:}) = true;
            
            % get the linear/row/col indices of the accessed cells in the
            % logical index
            switch (this.IndexingMethod)
                case 'cells'
                    i = find(indFlags);
                case 'rows'
                    find(any(indFlags, 2));
                case 'cols'
                    find(any(indFlags, 1));
            end
        end
        
        function c = getAvailableIndices(this, i, logicIdx)
        % returns a cell array of subs which exist according to logicIdx.
        %   i - cell array of subs
        %   logicIdx - a matrix of size numel(i{1}) [x numel(i{1}) x numel(i{1})...]
        %              of logical indexes which determine which indices in
        %              i are valid. as generated by mvvm.collections.ObservableArray.containsIndex
        % returns a cell array containing only the subs in i that are valid
        % according to logicIdx
            c = cell(1, numel(i));
            for j = 1:numel(i)
                currDimQuery = [num2cell(ones(1, j-1)) 1:numel(i{j}) num2cell(ones(1, numel(i)-j))];
                currDimIdx = i{j};
                c{j} = currDimIdx(logicIdx(currDimQuery{:}));
            end
        end
        
        function parseConfiguration(this, varargin)
            % configure input parser
            parser = inputParser();
            parser.CaseSensitive = false;
            parser.FunctionName = 'mvvm.collections.ObservableCell';
            
            % define parameters
            addParameter(parser, 'IndexingMethod', 'cells', @(x) this.validateIndexingMethod(x));
            
            % parse input
            parse(parser, varargin{:});
            
            % first of all, get binding manager
            this.IndexingMethod = parser.Results.IndexingMethod;
        end
        
        function validateIndexingMethod(this, method)
            assert(any(strcmp(method, {'cells', 'rows', 'cols'})), ...
                   'mvvm.collections.ObservableCell Indexing method must be either ''cells'', ''rows'' or ''cols''');
        end
    end
end

