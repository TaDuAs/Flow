classdef Pipeline < lists.IObservable
    %PIPELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        list (1,:) lists.PipelineTask;
        currentTaskIndex = 1;
    end
    
    properties (SetObservable)
        shouldPrintTaskTimespan = false;
    end
    
    methods % ctor dtor
        function this = Pipeline(shouldPrintTaskTimespan)
            if nargin >= 1
                this.shouldPrintTaskTimespan = shouldPrintTaskTimespan;
            end
        end
    end
    
    methods % ICollection methods
        function n = length(this)
            n = numel(this.list);
        end
        
        function b = isempty(this)
            b = builtin('isempty', this) || isempty(this.list);
        end
        
        function varargout = size(this, dim)
            varargout = cell(max(nargout, 1));
            
            if nargin > 1
                varargout{:} = size(this.list, dim);
            else
                varargout{:} = size(this.list);
            end
        end
        
        function value = getv(this, i)
            value = this.list(i);
        end
        
        function setv(this, i, value)
            if this.containsIndex(i)
                action = 'change';
            else
                action = 'add';
            end

            this.list(i) = value;
            
            % notify collection changed
            this.raiseCollectionChangedEvent(action, i);
        end
        
        function setVector(this, vector)
            prevkeys = this.keys();
            
            this.list = vector;
            
            newkeys = this.keys();
            
            % notify collection changed
            this.raiseCollectionChangedEvent('remove', prevkeys);
            this.raiseCollectionChangedEvent('add', newkeys);
        end
        
        function add(this, value)
            i = numel(this.list) + 1;
            this.list(i) = value;
            
            % notify collection changed
            this.raiseCollectionChangedEvent('add', i);
        end
        
        function removeAt(this, i)
            lists.Map
            this.list(i) = [];
            
            % notify collection changed
            this.raiseCollectionChangedEvent('remove', i);
        end
    end
    
    methods % IObservable methods
        function tf = containsIndex(this, i)
            if isnumeric(i)
                tf = i <= numel(this.list);
            elseif ischar(i) || isStringScalar(i)
                tf = ~isempty(this.findTaskByType(i));
            else
                this.raiseInvalidIndexTypeError();
            end
        end
        
        function keySet = keys(this)
            keySet = 1:numel(this.list);
        end
    end
    
    methods % Pipeline methods
        
        function b = hasPending(this)
            b = numel(this.list) >= this.currentTaskIndex;
        end
        
        function task = currentTask(this)
            task = [];
            
            if this.hasPending()                
                task = this.list(this.currentTaskIndex);
            end
        end
        
        function returnData = handle(this, data)
            if ~this.hasPending()
                returnData = data;
                return;
            end
            
            % Get current task
            task = this.currentTask();
            
            % Let current task process the data
            returnData = task.process(data);
            
            % Next task
            this.currentTaskIndex = this.currentTaskIndex + 1;
        end
        
        function init(this, settings)
            for i = 1:numel(this.list)
                this.list(i).init(settings);
            end
        end
        
        function returnData = run(this, data)
            this.currentTaskIndex = 1;
            returnData = data;
            while this.hasPending()
                if this.shouldPrintTaskTimespan
                    tic;
                end
                
                task = this.currentTask;
                returnData = this.handle(returnData);
                
                if this.shouldPrintTaskTimespan
                    disp(class(this));
                    toc;
                end
            end
        end
        
        function task = getTask(this, i)
            if isnumeric(i)
                if ~this.containsIndex(i)
                    throw(MException('lists:Pipeline:IndexOutOfRange', 'Index %d exeeds the length of the pipeline', i));
                end
                task = this.getv(i);
            elseif ischar(i) || isStringScalar(i)
                task = findTaskByType(i);
                if isempty(task)
                    throw(MException('lists:Pipeline:IndexOutOfRange', 'pipeline doesn''t contain specified task type %s', i));
                end
            else
                this.raiseInvalidIndexTypeError();
            end
        end
        
        function n = tasksNumber(this)
            n = numel(this.list);
        end
    end
    
    methods (Access=private)
        function raiseInvalidIndexTypeError(this)
            throw(MException('lists:Pipeline:InvalidIndex', 'Must specify task numeric index or type name'));
        end
        
        function task = findTaskByType(this, i)
            task = lists.PipelineTask.empty();
            wantedType = lower(i);
            for j = 1:numel(this.list)
                curr = this.getv(j);
                if isa(curr, i) || endsWith(lower(class(curr)), wantedType)
                    task = curr;
                    return;
                end
            end
        end
        
        function raiseCollectionChangedEvent(this, action, idx)
            args = lists.CollectionChangedEventData(action, idx);

            % raise event
            notify(this, 'collectionChanged', args);
        end
    end
    
end

