classdef List < handle & Simple.IO.MXML.IIterable & lists.ICollection
    % Self extending vector
    % This class implements the Simple.IO.MXML.IIterable abstract class, for
    % compatibility with Simple.IO.MXML serialization. If you don't care about Simple.IO.MXML,
    % all you need to do is remove the "& Simple.IO.MXML.IIterable" from class
    % decleration
    % 1. To use as a matrix, send 2D initial vector or specify emptyValue of a column vector
    % 2. To use as struct or class vector, specify empty value, the empty
    %    value should be a valid instance, not an empty vector of the
    %    specified type, as the reallocation method replicated the empty
    %    value to extend the vector.
    
    
    properties (Access = private)
       list = []; 
       typicalSize = 100;
       initialSize = 100;
       emptyValue = 0;
       lastIndex = 0;
       growth = 'l';
    end
    
    methods
        function this = List(a, b, c)
        % Initializes a new self prealocating list
        %   List() - Returns empty list.
        %            preallocation size - 100, empty value - 0
        %   List(vector) - Returns list with initial vector.
        %              preallocation size - 100, empty value - 0
        %   List(growth) - Returns empty list.
        %                  preallocation size - typicalSize, empty value - 0
        %   List(vector, growth) - Returns list with initial vector.
        %                          preallocation size - typicalSize, empty value - 0
        %   List(growth, emptyValue) - Returns list with initial vector.
        %                              preallocation size - typicalSize
        %                              empty value - emptyValue
        %   List(vector,typicalSize,emptyValue) - Returns list with initial vector.
        %                                     preallocation size - typicalSize
        %                                     empty value - 0
        % vector - The initial vector to populate the list with
        % growth - a numeric scalar representing the linear growth factor 
        %          for the list or a character array with the format
        %          '#e/l#' where the letter e or l represent the list 
        %          growth type (l for linear and e for exponential), and
        %          the number on the left of the letter represents the
        %          initial preallocated vector size and the number on the
        %          right of the letter represents the growth factor.
        % emptyValue - The value which represents empty cells in the list.
        %              preallocated cells are populated with emptyValue so
        %              it must be a non-empty vector which logically 
        %              represents an empty value.
            if nargin == 0
                % List()
                this.init([], [], []);
            elseif nargin == 1
                if length(a) > 1 && ~(ischar(a) && any(regexpi(a, '^\d*[el]\d*$')))
                    % List(vector)
                    this.init(a,[],[]);
                else
                    % List(typicalSize)
                    this.init([],a,[]);
                end
            elseif nargin == 3
                % List(vector, typicalSize, emptyValue)
                this.init(a, b, c);
            elseif nargin == 2
                if (ischar(a) && any(regexpi(a, '^\d*[el]\d*$'))) || size(b, 1) > 1
                    % List(typicalSize, emptyValue)
                    this.init([],a,b);
                else 
                    % List(vector, typicalSize)
                    this.init(a,b,[]);
                end
            end
        end
        
        function this = add(this, value)
            % You can add empty values by specifically adding the empty
            % value, but adding an empty vector does nothing
            if isempty(value)
                return;
            end
            
            % Appends a value\values to the end of the list
            this.set(this.lastIndex + 1, value);
        end
        
        function this = removeAt(this, i)
            % set the index to an empty value
            this.set(i, this.emptyValue);
        end
        
        function keySet = keys(this)
            keySet = 1:this.lastIndex;
        end
        
        function setv(this, value, i)
            this.set(i, value);
        end
        
        function this = set(this, index, value)
            hadIndexBefore = this.containsIndex(index);
            hadItemBefore = any(~this.isEntryEmpty(this.get(index)), 1);
            
            % sets the specified values in the specified index array
            if isempty(value)
                value = this.emptyValue;
            end
            
            % sets the value in the specified index. If the preallocated
            % list isn't long enough, more space is allocated
            [rows, cols] = size(value);
            if rows ~= size(this.list, 1)
                throw(MException('List:DimentionsMismatch', 'Added value must match list dimentions.'));
            end
            
            % if specified single index, stretch it to the length of the
            % specified value
            % for example:
            % list.set(5, 1:10), in this case index single scalar but value
            % is a vector of length 10, so index is changed accordingly to
            % index = 5:14, and the list will ensure that the preallocated
            % vector is at least 14 cells long.
            if length(index) == 1    
                maxIndex = index + cols - 1;
                index = index:maxIndex;
            else
                maxIndex = max(index);
            end
            
            % preallocate new vector if needed
            this.ensureListSize(maxIndex);
            
            % set value\s
            this.list(:, index) = value;

            % promote index
            if this.lastIndex < maxIndex
                this.lastIndex = maxIndex;
            end
            
            emptyEntries = any(this.isEntryEmpty(value), 1);
            removedItems = emptyEntries & hadIndexBefore & hadItemBefore;
            if any(removedItems)
                % notify item removed
                this.notify('collectionChanged', lists.CollectionChangedEventData('remove', index(removedItems)));
            end
     
            addedItems = ~emptyEntries & (~hadIndexBefore | ~hadItemBefore);
            if any(addedItems)
                % notify item added
                this.notify('collectionChanged', lists.CollectionChangedEventData('add', index(addedItems)));
            end

            changedItems = ~emptyEntries & hadIndexBefore & hadItemBefore;
            if any(changedItems)
                % notify item changed
                this.notify('collectionChanged', lists.CollectionChangedEventData('change', index(changedItems)));
            end
        end
        
        function value = getv(this, i)
            value = this.get(i);
        end
        
        function value = get(this, index)
            % Fetches the items in the specified index array
            if max(index) > this.lastIndex
                value = this.emptyValue;
            else
                value = this.list(:, index);
            end
        end
        
        function arr = vector(this)
            % Fetches the inner vector.
            % If you are removing items from the list at runtime, there
            % will be emty values inside this vector. In that case you 
            % should use the values function instead
            if this.lastIndex > 0
                arr = this.list(:, 1:this.lastIndex);
            else
                rowsNum = size(this.emptyValue,1);
                if (rowsNum > 1)
                    arr = zeros(rowsNum,0);
                else
                    arr = [];
                end
            end
        end
        
        function arr = values(this)
            % Discards empty value items in the middle of the vector 
            % (as a result of removing items) and returns the new vector
            % with only non-empty values
            vec = this.vector;
            
            if isempty(vec)
                arr = vec;
            else
                % prepare non-empty values mask
                if isstruct(vec)
                    mask = arrayfun(@(a) ~isequaln(a, this.emptyValue), vec);
                elseif isnumeric(vec) || islogical(vec)
                    mask = bsxfun(@ne, vec, this.emptyValue);
                elseif ischar(vec)
                    mask = bsxfun(@ne, double(vec), double(this.emptyValue));
                else
                    mask = arrayfun(@(a) ~eq(a, this.emptyValue), vec);
                end
                
                % fetch non-empty values
                arr = vec(:, sum(mask, 1)>0);
            end
        end
        
        function idx = findItems(this, criteria)
            % Finds items in the list which answer the specified criteria.
            % if criteria is a function handle, it is invoked and the
            % vector is sent, if it is a scalar value, then it is compared
            % against the vector.
            if isa(criteria, 'function_handle')
                idx = find(criteria(this.vector()));
            else
                idx = find(ismember(this.vector, criteria));
            end
        end
        
        function arr = foreach(this, do, gatherMode )
            % Runs on the entire list and returns an array of values based
            % processed by the specified method
            %   do - a function to process each value in the list
            %   gatherMode - specifies how to accumulate the processed data
            %                1 - vector
            %                2 - cell array
            %                3 - List
            
            if nargin < 3
                gatherMode  = 1;
            end
            
            arr = [];
            
            % iterate
            for i = 1:this.lastIndex
                % execute action
                x = do(this.list(:,i), i);
                if ismatrix(x) || isvector(x)
                    rowCount = size(x, 1);
                else
                    rowCount = 1;
                end
                
                if isempty(arr)
                    switch gatherMode
                        case 1
                            arr = zeros(rowCount, this.lastIndex);
                        case 2
                            arr = cell(rowCount, this.lastIndex);
                        case 3
                            arr = Simple.List([], this.lastIndex, zeros(rowCount,1));
                    end
                end
                
                % set in return value
                switch gatherMode
                    case 1
                        arr(:,i) = x;
                    case 2
                        if rowCount > 1
                            for j = 1:rowCount
                                arr{j,i} = x(j);
                            end
                        else
                            arr{i} = x;
                        end
                    case 3
                        arr.add(x);
                end
            end
        end
        
        function x = sum(this, accessor)
            % sums up the values in this list.
            % list.sum() - returns a column vector with the sums of each
            %              row in the list.
            % list.sum(foo) - sums the values generated by foo (function
            %                 handle) for each item separately
            % If this is a list of structures or classes, use the accessor
            % function handle to sum the properties you want
            if nargin > 1
                x = 0;
                v = this.values();
                for i = 1:length(v)
                    curr = accessor(v(:,i), i);
                    x = x + curr;
                end
            else
                x = sum(this.values(), 2);
            end
        end
        
        function this = setVector(this, arr, shouldExtend)
            this.lastIndex = length(arr);
            if nargin == 3 && shouldExtend
                this.list = this.extendVector(arr);
            else
                this.list = arr;
            end 
            
            if isempty(this.emptyValue) && ~strcmp(class(this.list), class(this.emptyValue))
                if ~isempty(this.list)
                    this.emptyValue = Simple.IO.MXML.newempty(this.list(1));
                else
                    this.emptyValue = Simple.IO.MXML.newempty(this.list);
                end
            end
        end
        
        function this = clear(this)
            this.list = this.generateStub();
            this.lastIndex = 0;
        end
        
        function b = isempty(this)
            b = this.lastIndex < 1;
        end
        
        function n = length(this)
            n = this.lastIndex;
        end
        
        function n = numel(this)
            n = this.length;
        end
        
        function b = any(this, condition)
            if nargin < 2
                b = this.length() > 0;
            else
                b = false;
                
                for i = 1:this.length()
                    if condition(this.get(i), i)
                        b = true;
                        return;
                    end
                end
            end
        end
        
        function arr = groupBy(this, groupingMethod, comparison)
            %groupBy generates a struct array with two fields:
            %   value - the group value
            %   elements - all the elements in that group
            % groupingMethod - function handle with the signature:
            %                  function groupValue = foo(x)
            %                  the function handle takes one input - a list
            %                  item and returns one output, the group value
            %                  for that list item.
            % comparison - function handle with the signature:
            %              function logical = foo(groupValue1, groupValue2)
            %              the function handle takes in two input arguments
            %              with the group values to compare and returns a
            %              logical value indicating their equality
            % arr - the struct array of groups
            % example:
            % list = Simple.List(struct('group', {'B', 'B', 'B', 'B', 'Q', 'Q', 'Q', 'Q', 'S'},...
            %                    'name', {'John', 'Paul', 'George', 'Ringo', 'Freddie', 'Brian', 'John', 'Roger', 'Elton'}),...
            %             10, struct('group', '', 'name', ''));
            % grparr = list.groupBy(@(x) x.group, @strcmp)
            % now grparr contains 3 groups with the values 'B', 'Q' and 'S'
            % group 'B' has the elements struct('group', {'B','B','B','B'}, 'name', {'John','Paul','George','Ringo'})
            % group 'Q' has the elements struct('group', {'Q','Q','Q','Q'}, 'name', {'Freddie','Brian','John','Roger'})
            % and group 'S' has one element - struct('group', 'S', 'name', 'Elton')
            groups = Simple.List([], this.length(), struct('value', [], 'elements', []));
            
            function b = groupExistsCondition(group, j)
                groupIndex = j;
                b = comparison(group.value, groupingValue);
            end
            
            groupIndex = 1;
            for i = 1:this.length
                currElement = this.get(i);
                groupingValue = groupingMethod(currElement);
                if groups.any(@groupExistsCondition)
                    currGroup = groups.get(groupIndex);
                    currGroup.elements = [currGroup.elements {currElement}];
                    groups.set(groupIndex, currGroup);
                else
                    groups.add(struct('value', groupingValue, 'elements', {{currElement}}));
                end
            end
            
            arr = groups.vector;
        end
        
        function s = size(this, dim)
            rows = size(this.list,1);
            s = [rows this.lastIndex];
            if nargin > 1 && ~isempty(dim)
                s = s(dim);
            end
        end
        
        function n = allocatedLength(this)
            n = size(this.list,2);
        end
        
        function b = containsIndex(this, i)
            b = this.lastIndex >= i;
        end
    end
    
    methods (Access = private)
        function b = isEntryEmpty(this, item)
            if isstruct(this.emptyValue)
                b = arrayfun(@(a) isequal(a, this.emptyValue), item);
            else
                b = arrayfun(@(a) eq(a, this.emptyValue), item);
            end
        end
        
        function stub = generateStub(this, stubLength)
            if nargin < 2 || isempty(stubLength) || stubLength < 1
                stubLength = this.typicalSize;
            end
            stub = repmat(this.emptyValue, 1, stubLength);
        end
        
        function this = ensureListSize(this, neededSize)
            actualListSize = length(this.list);
            if neededSize > actualListSize
                if this.growth == 'e'
                    extendByThisMuch = max(actualListSize*(this.typicalSize-1), (neededSize-actualListSize)*this.typicalSize);
                else
                    extendByThisMuch = neededSize - actualListSize + this.typicalSize;
                end
                this.list = this.extendVector(this.list, extendByThisMuch);
            end
        end
        
        function arr = extendVector(this, vector, extendByThisMuchAtLeast)
            if nargin < 3; extendByThisMuchAtLeast = this.typicalSize; end
            currentListLength = length(vector);
            
            % Start with a vector size at least as big as initialSize
            if currentListLength < this.initialSize
                extendByThisMuchAtLeast = max(this.initialSize - currentListLength, extendByThisMuchAtLeast);
            end
            
            if this.growth == 'e'
                % extend vector size exponentially
                extendByThisMuch = max([(this.typicalSize-1)*length(vector), extendByThisMuchAtLeast]);
            else
                % extend vector size linearly
                extendByThisMuch = max(this.typicalSize, extendByThisMuchAtLeast);
            end
            
            % reallocate vector
            arr = [vector this.generateStub(extendByThisMuch)];
        end
        
        function init(this, vector, typicalSize, emptyVal)
            if ~isempty(typicalSize)
                if ischar(typicalSize)
                    tokens = regexpi(typicalSize, '^(?<initial>\d*)(?<growth>[le])(?<factor>\d*)$', 'names');
                    if isempty(tokens)
                        throw(MException('List:InvalidGrowthIndicator', 'Growth indicator must be a number or a string of the format ''#e/l#'''));
                    end
                    
                    if ~isempty(tokens.growth)
                        this.growth = tokens.growth;
                    end
                    
                    if ~isempty(tokens.initial)
                        this.initialSize = str2double(tokens.initial);
                    end
                    
                    if ~isempty(tokens.factor)
                        factor = str2double(tokens.factor);
                        if factor > 1
                            this.typicalSize = factor;
                        else
                            this.typicalSize = Simple.cond(this.growth == 'e', 2, 100);
                        end
                    else
                        this.typicalSize = 2;
                    end
                elseif isnumeric(typicalSize)
                    this.typicalSize = typicalSize;
                else
                    throw(MException('List:InvalidGrowthIndicator', 'growth indicator must be a scalar or a character vector with the format ''#e/l#'''));
                end
            end
            
            if ~isempty(emptyVal)
                this.emptyValue = emptyVal;
            elseif size(vector,1) > 1
                this.emptyValue = zeros(size(vector,1),1);
            end
            
            this.setVector(vector, true);
        end
    end
    
end

