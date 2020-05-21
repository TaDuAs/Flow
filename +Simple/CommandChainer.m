classdef CommandChainer < handle
    %CommandChainer Wraps objects (struct/class) to allow chaining of set commands
    % This little tool is handy for inline commands, I.E chaining several
    % commands within closures or anonymous functions:
    %       @(x) invoke(set(set(set(CommandChainer(x), 'prop1', value1)), 'prop2', value2), 'prop3', value3), 'doSomething');
    %
    % And even:
    %       @(x) invoke(execute(set(execute(set(set(CommandChainer(x), 'prop1', value1), 'prop2', value2), 'foo', arg1, arg2, arg3), 'prop3', value3), 'foo2', arg), 'doSomething');
    % 
    % Unfortunately, matlab doesn't allow the more readable dot indexing in
    % anonymous funcions like that:
    %       @(x) CommandChainer(x)...
    %               .set('prop1', value1)...
    %               .set('prop2', value2)...
    %               .set('prop3', value3)...
    %               .object.doSomething();
    
    properties
        object;
        metaObj;
        methodDescriptors = struct();
        result;
        resultCell;
    end
    
    methods
        function this = CommandChainer(obj)
            Simple.obsoleteWarning();
            this.object = obj;
        end
        
        function obj = getObject(this)
            obj = this.object;
        end
        
        function this = set(this, propName, value)
            %set - Sets the value of a field/property
            % returns this for further commands
            this.object.(propName) = value;
        end
        
        function value = get(this, propName)
            %set - Sets the value of a field/property
            % returns this for further commands
            value = this.object.(propName);
        end
        
        function this = execute(this, funcName, varargin)
            %execute - invokes a function with the name funcName and sends
            % arguments specified in varargin
            % output args are saved in resultCell and result properties
            % returns this for further commands
            
            descriptor = this.getMethodDescriptor(funcName);
            this.resultCell = cell(1, length(descriptor.OutputNames));
            
            try
                [this.resultCell{:}] = this.object.(funcName)(varargin{:});
            catch ex
                if strcmp(ex.identifier, 'MATLAB:TooManyOutputs')
                    this.resultCell = {};
                    this.object.(funcName)(varargin{:});
                    this.methodDescriptors.(funcName).OutputNames = {};
                else
                    ex.rethrow();
                end
            end
            
            if isempty(this.resultCell)
                this.result = [];
            else
                this.result = this.resultCell{1};
            end
        end
        
        function varargout = invoke(this, funcName, varargin)
            %execute - invokes a function with the name funcName and sends
            % arguments specified in varargin
            % returns the results of funcName into the required output
            % argument list.
            % If called with no output args, returns the first
            % Don't use this method for object methods with no output
            % arguments.
            varargout = cell(1, max(nargout, 1));
            [varargout{:}] = this.object.(funcName)(varargin{:});
        end
    end
    
    methods (Access=private)
        function descriptor = getMethodDescriptor(this, funcName)
            if isfield(this.methodDescriptors, funcName)
                descriptor = this.methodDescriptors.(funcName);
            else
                if isobject(this.object)
                    if isempty(this.metaObj)
                        this.metaObj = meta.class.fromName(class(this.object));
                    end
                    
                    descriptor = this.metaObj.MethodList(strcmp({this.metaObj.MethodList.Name}, funcName));
                    this.methodDescriptors.(funcName) = descriptor;
                else
                    % object is a struct
                    descriptor = struct();
                    fh = this.object.(funcName);
                    if nargin(fh) >= 0 && nargout(fh) >= 0
                        % invent arg names
                        descriptor.InputNames = strcat('a', cellfun(@num2str, num2cell(1:nargin(fh)), 'UniformOutput', false));
                        descriptor.OutputNames = strcat('a', cellfun(@num2str, num2cell(1:nargout(fh)), 'UniformOutput', false));
                    else
                        % handle anonymous function
                        fhText = func2str(fh);
                        match = regexp(fhText, '^@\s*\((?<args>[^\)]*)\).*', 'names');
                        if ~isempty(match)
                            % anonymous functions
                            descriptor.InputNames = regexp(match.args, '\s*,\s*', 'split');
                        else
                            descriptor.InputNames = {};
                        end
                            
                        % anonymous functions can have 0 or 1 output
                        % args. Let's guess 1 and fix it later if
                        % theres an exception
                        descriptor.OutputNames = {'a1'};
                    end
                    this.methodDescriptors.(funcName) = descriptor;
                end
            end
        end
    end
end

