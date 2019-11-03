classdef ClassAnalyzerCtor < mfc.IMCtor
    properties
        Ctor mfc.IMCtor = mfc.MCtor.empty();
        Properties = {};
        CtorParams = {};
        ByValueStringCtorParamsMask logical;
        OptionalKeysCtorParamsIndex double;
        FieldExtractCtorParamsIndex double;
        DependencyInjectionCtorParamsIndex double;
        CtorDefaultValuesExtractor mfc.extract.IJitPropertyExtractor = mfc.extract.StructJitExtractor.empty();
        IoCContainer IoC.IContainerGetter = IoC.ContainerGetter.empty();
    end
    
    methods
        function this = ClassAnalyzerCtor(ctor, injector)
            if isa(ctor, 'mfc.IMCtor')
                this.Ctor = ctor;
            else
                this.Ctor = mfc.MCtor(ctor);
            end
            
            if nargin >= 2 && ~isempty(injector)
                this.IoCContainer = injector;
            end
            
            this.analyzeClass();
        end
        
        function obj = build(this, extractor)
            % build instance, inject all ctor params
            ctorParams = this.prepareParamsArrayForCtorInjection(extractor);
            obj = this.Ctor.build(ctorParams{:});
            
            % Inject all available properties
            props = this.Properties;
            for i = 1:numel(props)
                currProp = props{i};
                if extractor.hasProp(currProp)
                    obj.(currProp) = extractor.get(currProp);
                end
            end
        end
        
        function type = getTypeName(this)
            type = this.Ctor.getTypeName();
        end
    end
    
    methods (Access=protected)
        function ctorParams = prepareParamsArrayForCtorInjection(this, extractor)
            % duplicate ctor params array
            ctorParams = this.CtorParams;
            
            % monitor fields that have no value in the extractor
            removeFields = false(size(ctorParams));
            
            % replace all dependency injection params with the actual
            % dependencies from the container
            for i = this.DependencyInjectionCtorParamsIndex
                currDependency = ctorParams{i};
                if this.IoCContainer.hasDependency(currDependency)
                    ctorParams{i} = this.IoCContainer.get(currDependency);
                else
                    % if the extracted field doens't exist, remove current
                    % param from the ctor injection array
                    removeFields(i) = true;
                    
                    % if the current parameter is an optional key-value
                    % type parameter, remove the key as well
                    if ismember(i-1, this.OptionalKeysCtorParamsIndex)
                        removeFields(i-1) = true;
                    end
                end
            end
            
            % replace all field extractions with field values, or mark them
            % for removal if they don't exist
            for i = this.FieldExtractCtorParamsIndex
                currProp = ctorParams{i};
                
                % check if extractor has that field
                if extractor.hasProp(currProp)
                    % extract field value and put it in the ctor params
                    % array
                    ctorParams{i} = extractor.get(currProp);
                elseif this.CtorDefaultValuesExtractor.hasProp(currProp)
                    % extract field default value and put it in the ctor 
                    % params array
                    ctorParams{i} = this.CtorDefaultValuesExtractor.get(currProp);
                else
                    % if the extracted field doens't exist, remove current
                    % param from the ctor injection array
                    removeFields(i) = true;
                    
                    % if the current parameter is an optional key-value
                    % type parameter, remove the key as well
                    if ismember(i-1, this.OptionalKeysCtorParamsIndex)
                        removeFields(i-1) = true;
                    end
                end
            end
            
            ctorParams(removeFields) = [];
        end
        
        function analyzeClass(this)
            % Try to dynamically generate a ctor for that class
            
            typeName = this.getTypeName();
            
            % validate specified name is a name of a class
            classInfo = meta.class.fromName(typeName);
            if isempty(classInfo)
                error(['specified class ' className ' is not a valid matlab class']);
            end
            
            if classInfo <= ?mfc.IDescriptor || classInfo <= ?mfc.IDescriptorStruct
                this.inspectDescriptorClass(classInfo);
            end

            % find all public properties for injection. Remove all ctor
            % injections
            publicProps = classInfo.PropertyList(strcmp({classInfo.PropertyList.SetAccess}, 'public'));
            publicProps = {publicProps.Name};
            publicProps(ismember(publicProps, this.CtorParams(this.FieldExtractCtorParamsIndex))) = [];
            this.Properties = publicProps;
        end
        
        function inspectDescriptorClass(this, classInfo)
            % get ctor params description
            emptyTypeArray = feval([classInfo.Name, '.empty']);
            [initParams, defaultValues] = getMfcInitializationDescription(emptyTypeArray);
            this.CtorDefaultValuesExtractor = mfc.extract.NameValueJitExtractor(defaultValues);

            % ctor params which are strings - all the important stuff
            % are strings...
            strParamMask = cellfun(@(p) ischar(p) || isStringScalar(p), initParams);

            % const string values
            byValueStringMask = strParamMask;
            byValueStringMask(strParamMask) = cellfun(@(s) startsWith(s, '$'), initParams(strParamMask));

            % optional key-value ctor params
            optionalKeysMask = strParamMask;
            optionalKeysMask(strParamMask) = cellfun(@(s) startsWith(s, '@'), initParams(strParamMask));

            % ctor parameters to be extracted from fields
            fieldExtractorsMask = strParamMask;
            fieldExtractorsMask(strParamMask) = cellfun(@(s) any(regexpi(s, '^[&a-z]')), initParams(strParamMask));
            initParams(fieldExtractorsMask) = cellfun(@char, initParams(fieldExtractorsMask), 'UniformOutput', false);

            % dependency injection parameters
            diMask = strParamMask;
            diMask(strParamMask) = cellfun(@(s) startsWith(s, '%'), initParams(strParamMask));
            if any(diMask) && isempty(this.IoCContainer)
                throw(MException('mfc:ClassAnalyzerCtor:InvalidDependencyInjection', ...
                    'Class %s requires parameters to be injected from dependency injection toolbox. Set a dependency injector for the mfc.MFactory or implement a custom ctor for this class', ...
                    this.getTypeName()));
            end
            
            % remove all unneeded prefixes
            initParams(fieldExtractorsMask) = regexprep(initParams(fieldExtractorsMask), '^&', '');
            initParams(optionalKeysMask) = cellfun(@(s) regexprep(s, '^@', ''), initParams(optionalKeysMask), 'UniformOutput', false);
            initParams(byValueStringMask) = cellfun(@(s) regexprep(s, '^\$', ''), initParams(byValueStringMask), 'UniformOutput', false);
            initParams(diMask) = cellfun(@(s) regexprep(s, '^\%', ''), initParams(diMask), 'UniformOutput', false);

            this.CtorParams = initParams;
            this.ByValueStringCtorParamsMask = byValueStringMask;
            this.OptionalKeysCtorParamsIndex = find(optionalKeysMask);
            this.FieldExtractCtorParamsIndex = find(fieldExtractorsMask);
            this.DependencyInjectionCtorParamsIndex = find(diMask);
        end
    end
end

