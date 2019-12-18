classdef Pipeline < mcol.ICollection
    %PIPELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        list mcol.PipelineTask;
        currentTaskIndex = [];
    end
    
    properties (SetObservable)
        shouldPrintTaskTimespan = false;
    end
    
    methods % ctor dtor
        function this = Pipeline(shouldPrintTaskTimespan)
            this.list = Simple.List(Simple.PipelineTask.empty(), 10, Simple.PipelineTask());
            this.currentTaskIndex = 1;
            
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
            b = isempty(this.list);
        end
        
        function b = any(this, condition)
            if nargin < 2
                b = this.length() > 0;
            else
                b = any(arrayfun(condition, this.list));
            end
        end
        
        function varargout = size(this, dim)
            varargout = cell(max(nargout, 1));
            
            if nargin > 1
                varargout{:} = size(this.list, dim);
            else
                varargout{:} = size(this.list);
            end
        end
        
        function value = get(this, i)
            value = this.list(i);
        end
        
        function set(this, i, value)
            this.list(i) = value;
        end
        
        function setVector(this, vector)
            this.list = vector;
        end
        
        function add(this, value)
            
        end
    end
    
    methods % Pipeline methods
        
        function b = hasPending(this)
            b = numel(this.list) >= this.currentTaskIndex;
        end
        
        function task = currentTask(this)
            task = [];
            
            if this.hasPending()                
                task = this.list.get(this.currentTaskIndex);
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
            for i = 1:this.list.length()
                this.list.get(i).init(settings);
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
        
        function this = addTask(this, task)
            this.list.add(task);
        end
        
        function this = removeTask(this, i)
            % remove task at specified index
            this.list.remove(i);
            
            % reset tasks list
            this.list.setVector(this.list.values);
        end
        
        function task = getTask(this, i)
            if isnumeric(i)
                if i > this.list.length()
                    error(['index ' num2str(i) ' exceeds pipeline length']);
                end
                task = this.list.get(i);
            elseif ischar(i)
                for j = 1:this.list.length()
                    curr = this.list.get(j);
                    if isa(curr, i) || endsWith(class(curr), i)
                        task = curr;
                        return;
                    end
                end
                error(['pipeline doesn''t contain specified task type ' i]);
            else
                error('must specify task numeric index or type name');
            end
        end
        
        function n = tasksNumber(this)
            n = this.list.length();
        end
    end
    
end

