classdef Dependency < handle & matlab.mixin.Heterogeneous
    % IoC.Dependency generates an instance of a specified dependency for
    % injection
    
    properties
        Id;
    end
    
    properties (Access=protected)
        IoCContainer IoC.Container;
        Ctor function_handle;
        Arguments;
        NameValueArgs;
        PropertyInjections struct;
        Type char;
    end
    
    methods
        function this = Dependency(ioc, id, ctor, varargin)
            this.IoCContainer = ioc;
            this.Id = id;
            this.Ctor = ctor;
            [this.Arguments, ~, ~, this.NameValueArgs, this.PropertyInjections] = this.getCtorAndPropInjecctions(varargin, struct());
            this.validateSingleNVArgRepeat(this.NameValueArgs(1:2:end));
        end
        
        function type = getType(this)
            if isempty(this.Type)
                this.build();
            end
            type = this.Type;
        end
        
        function obj = build(this, varargin)
            % prepare all injections
            [ctorInjections, propInjections] = this.prepareDependenciesForInjection(this.Arguments, varargin);
            
            % prepare ctor dependencies for injection
            ctorInjections = this.setInjectionValues(ctorInjections);
            
            % build dependency using ctor injections
            obj = this.Ctor(ctorInjections{:});
            
            % save the type of the dependency
            if isempty(this.Type)
                this.Type = class(obj);
            end
            
            % inject all property injections
            props = fieldnames(propInjections);
            for i = 1:numel(props)
                currProp = props{i};
                
                % prepare curr property dependency for injection
                dependencyValue = this.setInjectionValues({propInjections.(currProp)});
                
                % inject dependency
                obj.(currProp) = dependencyValue{1};
            end
        end
        
    end
    
    methods (Access={?IoC.Container})
        function new = duplicateFor(this, IoCContainer)
            new = this.generateCopyInstance(IoCContainer);
            this.copyArgumentsTo(new);
        end
    end
    
    methods (Access=protected)
        function [ctorInjections, propertyInjections] = prepareDependenciesForInjection(this, args, optionalArgs)
            % Prepare the final list of injections.
            %
            % OptionalArgs must be a list of name-value pairs.
            % The names must correspond to dependencies in the ctor
            % injection list or to property names of the dependency class.
            
            % Validate optional args is a valid name-value pair list
            % If the number of elements in the list is not an even number, 
            % it can't be name-value pair list.
            % If the odd elements of the list are not all char or string,
            % then the names aren't valid, therefore not name-value pairs.
            if mod(numel(optionalArgs), 2) > 0 ||... 
               any(cellfun(@(name) ~ischar(name) && ~isStringScalar(name), optionalArgs(1:2:numel(optionalArgs)))) 
                throw(MException("IoC:Dependency:InvalidOptionalDependencies",...
                    "Optional dependencies must be specified as name-value pairs coresponding to either ctor dependencies, or property names of the class"));
            end
            ctorInjections = this.Arguments;
            nvInjections = this.NameValueArgs;
            propertyInjections = this.PropertyInjections;
            
            % prepare final property injections and optional ctor injections
            if ~isempty(optionalArgs)
                [optNameValueArgs1, ctorInjOverrideIndex, ctorInjOverrideValue, optNameValueArgs2, propertyInjections] = this.getCtorAndPropInjecctions(optionalArgs, this.PropertyInjections);
                optNameValueArgs1(1:2:end) = cellfun(@(s) strcat('@', s), optNameValueArgs1(1:2:end), 'UniformOutput', false);
                optNVArgs = [optNameValueArgs1, optNameValueArgs2];
                this.validateSingleNVArgRepeat(optNVArgs(1:2:end));
                
                %
                % override default ctor injections
                ctorInjections(ctorInjOverrideIndex) = ctorInjOverrideValue;
                
                %
                % override default ctor name-value injections
                overrideNamesIdx = 1:2:numel(optNVArgs);
                overrideNames = string(optNVArgs(overrideNamesIdx));
                originalNamesIdx = 1:2:numel(nvInjections);
                originalNames = string(nvInjections(originalNamesIdx));
                [~, overrideIntIdx, originalIntIdx] = intersect(overrideNames, originalNames);
                nvInjections(originalNamesIdx(originalIntIdx) + 1) = optNVArgs(overrideNamesIdx(overrideIntIdx) + 1);
                
                %
                % append added ctor name-value injections
                %
                % find the names missing from the original n-v args
                [~, addedIdx] = setdiff(overrideNames, originalNames);
                
                % make an index vector containing the names and the values
                iii = [overrideNamesIdx(addedIdx); overrideNamesIdx(addedIdx)+1];
                
                % extract the missing name-value args and append them at
                % the end of the args array
                nvInjections = [nvInjections optNVArgs(iii(:)')];
            end
            
            % prepare final ctor injections arguments
            ctorInjections = [ctorInjections nvInjections];
        end
        
        function [ctorInj, ctorInjOverrideIndex, ctorInjOverrideValue, ctorNVArgs, propInjStruct] = getCtorAndPropInjecctions(this, args, propInjStruct)
            
            % extract propety injection args and set struct
            [propInjNamesMask, propInjValueMask] = this.findNameValueArgs(args, '&');
            for i = find(propInjNamesMask)
                propInjStruct.(strip(args{i}, 'left', '&')) = this.evaluateInjectionItem(args{i+1});
            end
            
            % extract ctor name-value injection args
            [ctorNVNamesMask, ctorNVValueMask] = this.findNameValueArgs(args, '@');
            ctorNVArgs = args(ctorNVNamesMask | ctorNVValueMask);
            ctorNVArgs(2:2:end) = cellfun(@this.evaluateInjectionItem, ctorNVArgs(2:2:end), 'UniformOutput', false);
            
            % extract ctor arg indexex overides
            ctorInjOverrideIndex = zeros(1,0);
            ctorInjOverrideValue = cell(1,0);
            [ctorIdxNamesMask, ctorIdxValueMask] = this.findNameValueArgs(args, '#');
            if any(ctorIdxNamesMask)
                idxNames = string(args(ctorIdxNamesMask));
                ctorInjOverrideValue = cellfun(@this.evaluateInjectionItem, args(ctorIdxValueMask), 'UniformOutput', false);

                % validate indices names
                if any(arrayfun(@isempty, regexp(idxNames, '^#\d+$')))
                    throw(MException('IoC:Dependency:InvalidIndexedArgument', 'Dynamic indexed arguments specified by the "#" prefix must be a hash "#" followed by an integer greater than zero'));
                end
                ctorInjOverrideIndex = str2double(regexp(idxNames, '\d+', 'match', 'once'));

                % validate indices
                if any(isnan(ctorInjOverrideIndex) | ctorInjOverrideIndex < 1)
                    throw(MException('IoC:Dependency:InvalidIndexedArgument', 'Dynamic indexed arguments specified by the "#" prefix must be a hash "#" followed by an integer greater than zero'));
                end
            end
            
            % extract regular ctor injection args
            pairsMask = propInjNamesMask | propInjValueMask | ctorNVNamesMask | ctorNVValueMask | ctorIdxNamesMask | ctorIdxValueMask;
            ctorInj = args(~pairsMask);
        end
        
        function [nameMask, valueMask] = findNameValueArgs(this, args, prefix)
            nameMask = cellfun(@(a) (ischar(a) || isStringScalar(a)) && startsWith(a, prefix), args);
            valueMask = [false, nameMask(1:end-1)];
        end
        
        function validateSingleNVArgRepeat(this, names)
            [~, unqIdx] = unique(string(names));
            if numel(unqIdx) < numel(names)
                throw(MException('IoC:Dependency:DuplicateNameValuePair', 'Ambigous Name-Value pair ctor injection argument. Must set only one name value pair'));
            end
        end
        
        function inj = evaluateInjectionItem(this, inj)
            if ischar(inj) && ~startsWith(inj, '$')
                inj = string(inj);
            end
        end
        
        function args = setInjectionValues(this, args)
            stringsMask = cellfun(@(arg) ischar(arg) || isstring(arg), args);
            servicesMask = cellfun(@(arg) isa(arg, 'IoC.Injectable') || ((ischar(arg) || isStringScalar(arg)) && ~any(regexp(arg, '^[$@]'))), args);
            byValueStrings = stringsMask & ~servicesMask;
            
            if any(servicesMask)
                services = this.IoCContainer.get(args(servicesMask));
                if iscell(services)
                    args(servicesMask) = services;
                else
                    args(servicesMask) = {services};
                end
            end
            if any(byValueStrings)
                args(byValueStrings) = cellfun(@(str) regexprep(str, "^[$@]", ""), args(byValueStrings), 'UniformOutput', false);
            end
        end
        
        function new = generateCopyInstance(this, ioCContainer)
            new = IoC.Dependency(ioCContainer, this.Id, this.Ctor);
        end
        
        function copyArgumentsTo(this, other)
            other.Arguments = this.Arguments;
            other.NameValueArgs = this.NameValueArgs;
            other.PropertyInjections = this.PropertyInjections;
            other.Type = this.Type;
        end
    end
end