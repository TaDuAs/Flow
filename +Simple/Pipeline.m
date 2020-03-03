classdef Pipeline < handle
    %PIPELINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable)
        list = [];
        currentTaskIndex = [];
        shouldPrintTaskTimespan = false;
    end
    
    methods
        function this = Pipeline(shouldPrintTaskTimespan)
            this.list = Simple.List(Simple.PipelineTask.empty(), 10, Simple.PipelineTask());
            this.currentTaskIndex = 1;
            
            if nargin >= 1
                this.shouldPrintTaskTimespan = shouldPrintTaskTimespan;
            end
        end
        
        function b = hasPending(this)
            b = this.list.length() >= this.currentTaskIndex;
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

