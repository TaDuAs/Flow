classdef ObservableArray < lists.IObservable
    %OBSERVABLECELL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Array;
        IndexingMethod ;
    end
    
    methods % property accessors
        function set.IndexingMethod(this, value)
            this.validateIndexingMethod(value);
            this.IndexingMethod = value;
        end
    end
    
    methods % lists.ICollection
        function b = containsIndex(this, varargin)
            if nargin > 2
                i = varargin;
            else
                i = varargin{1};
            end
            
            % handle multidimentional subs
            if iscell(i)
                % assume index exists
                b = true(cellfun('length', i));

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
            if builtin('isempty', this)
                b = true;
            else
                b = isempty(this.Array);
            end
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
            elseif islogical(i) && (all(size(i) > 1) || all(size(i) == size(this.Array)))
                value = this.Array(i);
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
            
            %
            % DO NOT CHANGE SUBSASGN EXPLICIT INVOCATION!
            % I Don't know why, but it doesn't work when asigning using
            % regular indexing rather than explicitly calling subsasgn.
            % When I debugged it, subsasgn overload was not invoked.
            %
            
            if iscell(i)
                if iscell(this.Array) && all(cellfun('length', i) == 1) && all(cellfun(@(c) ~strcmp(c,':'), i))
                    [~] = subsasgn(this, substruct('{}', i), value);
                else
                    [~] = subsasgn(this, substruct('()', i), value);
                end
            elseif islogical(i) && (all(size(i) > 1) || all(size(i) == size(this.Array)))
                [~] = subsasgn(this, substruct('()', {i}), value);
            else
                switch (this.IndexingMethod)
                    case 'cells'
                        if iscell(this.Array) && numel(i) == 1
                            [~] = subsasgn(this, substruct('{}', {i}), value);
                        else
                            [~] = subsasgn(this, substruct('()', {i}), value);
                        end
                    case 'rows'
                        [~] = subsasgn(this, substruct('()', {i, ':'}), value);
                    case 'cols'
                        [~] = subsasgn(this, substruct('()', {':', i}), value);
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
            
            arg = lists.CollectionChangedEventData('remove', indexingMethodIndices, i);
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
        
        function setVector(this, arr)
            this.Array = arr;
        end
        
        function add(this, value)
            switch (this.IndexingMethod)
                case 'cells'
                    i1 = numel(this.Array) + 1;
                    i2 = numel(value);
                case 'rows'
                    i1 = this.size(1) + 1;
                    i2 = size(value, 1);
                case 'cols'
                    i1 = this.size(2) + 1;
                    i2 = size(value, 2);
            end
            
            this.setv(value, i1:i2);
        end
    end
    
    methods % indexing
        function varargout = subsref(A, S)
            if nargout == 0
                % this is for printing this indexing output to the command
                % window even if no output arguments were set which is the
                % standard behavior in matlab
                varargout = cell(1);
            else
                varargout = cell(1,nargout);
            end
            
            if any(strcmp(S(1).type, {'()', '{}'}))
                varargout{:} = subsref(A.Array, S);
            else
                subs1 = S(1).subs;
                
                if ~isempty(findprop(A, subs1))
                    % handle properties
                    [varargout{:}] = builtin('subsref', A, S(1));
                else
                    % handle functions
                    
                    % this prevents an error when a method has no output
                    % arguments
                    mc = metaclass(A);
                    methodMask = strcmp(subs1, {mc.MethodList.Name});
                    if any(methodMask)
                        methodDescriptor = mc.MethodList(methodMask);
                        if numel(methodDescriptor.OutputNames) < 1
                            varargout = {};
                        end
                    end
                    
                    % execute indexing
                    [varargout{:}] = builtin('subsref', A, S);
                end
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
                        A.notify('collectionChanged', lists.CollectionChangedEventData('remove', indexMethodIdx, isubs));
                    end

                    % notify added
                    addedIdx = hasIndexAfter & ~hadIndexBefore;
                    if any(addedIdx)
                        isubs = A.getAvailableIndices(idx, addedIdx);
                        indexMethodIdx = this.convertSubsCellToIndexingMethodIndices(isubs);
                        A.notify('collectionChanged', lists.CollectionChangedEventData('add', indexMethodIdx, isubs));
                    end

                    % notify changed
                    changedIdx = hasIndexAfter & hadIndexBefore;
                    if any(changeIdx)
                        isubs = A.getAvailableIndices(idx, changedIdx);
                        indexMethodIdx = this.convertSubsCellToIndexingMethodIndices(isubs);
                        A.notify('collectionChanged', lists.CollectionChangedEventData('change', indexMethodIdx, isubs));
                    end
                end
            else
                A = builtin('subsasgn', A, S, B);
            end
        end
        
        function n = numArgumentsFromSubscript(A, S, indexingContext)
            if any(strcmp(S(1).type, {'()', '{}'}))
                n = builtin('numArgumentsFromSubscript', A.Array, S, indexingContext);
            elseif strcmp(S(1).type, '.') && ~isempty(findprop(A, S(1).subs))
                n = 1;
            else
                n = builtin('numArgumentsFromSubscript', A, S, indexingContext);
            end
        end
        
        function ind = end(A, k, n)
            if n > 1
                ind = size(A.Array, k);
            else
                ind = numel(A.Array);
            end
        end
    end
    
    methods % ctor
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
    
    methods %polling methods
        function n = numel(this)
            n = numel(this.Array);
        end
        
        function disp(this)
            if builtin('isempty', this)
                fprintf('  empty %s\n\r', class(this));
            else
                fprintf('  %s indexed by ''%s''\n\r', class(this), this.IndexingMethod);
                disp(this.Array);
            end
        end
        
        function this = repmat(this, varargin)
            this.Array = repmat(this.Array, varargin{:});
        end
        
        function this = repelem(this, varargin)
            this.Array = repelem(this.Array, varargin{:});
        end
        
        function h = plot(this, varargin)
            h = plot(this.Array, varargin{:});
        end
    end
    
    methods % concatenation
        function this = vertcatself(this, varargin)
            this.concatSelf(1, true, varargin{:});
        end
        
        function newArray = vertcat(this, varargin)
            newArray = this.concat(1, varargin{:});
        end
        
        function this = horzcatself(this, varargin)
            this.concatSelf(2, true, varargin{:});
        end
        
        function newArray = horzcat(this, varargin)
            newArray = this.concat(2, varargin{:});
        end
        
        function this = concatSelf(this, dim, observeChanges, varargin)
            if numel(dim) == 1 && dim == 1
                catFunc = @vertcat;
            elseif numel(dim) == 1 && dim == 2
                catFunc = @horzcat;
            else
                error ('lists.ObservableArray only supports 2D concatenation');
            end
            
            nItemsStart = size(this, dim);
            
            for i = 1:numel(varargin)
                elm = varargin{i};
                if isa(elm, 'lists.ObservableArray')
                    this.Array = catFunc(this.Array, elm.Array);
                else
                    this.Array = catFunc(this.Array, elm);
                end
            end
            
            if observeChanges
                nAddedItems = sum(cellfun(@(c) size(c, dim), varargin));

                % raise collection changed event
                addedSubscripts = {nItemsStart+(1:nAddedItems), ':'};
                indexingMethodIndices = this.convertSubsCellToIndexingMethodIndices(addedSubscripts);
                arg = lists.CollectionChangedEventData('add', indexingMethodIndices, addedSubscripts);
                this.notify('collectionChanged', arg);
            end
        end
        
        function newArray = concat(this, dim, varargin)
            newArray = lists.ObservableArray(this.Array);
            
            newArray.concatSelf(dim, false, varargin{:});
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
                    i = find(any(indFlags, 2));
                case 'cols'
                    i = find(any(indFlags, 1));
            end
        end
        
        function c = getAvailableIndices(this, i, logicIdx)
        % returns a cell array of subs which exist according to logicIdx.
        %   i - cell array of subs
        %   logicIdx - a matrix of size numel(i{1}) [x numel(i{1}) x numel(i{1})...]
        %              of logical indexes which determine which indices in
        %              i are valid. as generated by lists.ObservableArray.containsIndex
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
            parser.FunctionName = 'lists.ObservableCell';
            
            % define parameters
            addParameter(parser, 'IndexingMethod', 'cells', @(x) this.validateIndexingMethod(x));
            
            % parse input
            parse(parser, varargin{:});
            
            % first of all, get binding manager
            this.IndexingMethod = parser.Results.IndexingMethod;
        end
        
        function validateIndexingMethod(this, method)
            assert(any(strcmp(method, {'cells', 'rows', 'cols'})), ...
                   'lists.ObservableCell Indexing method must be either ''cells'', ''rows'' or ''cols''');
        end
    end
end

