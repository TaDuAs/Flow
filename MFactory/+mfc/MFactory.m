classdef MFactory < mfc.IFactory
% mfc.MFactory is a class-factory.
% mfc.MFactory exposes three APIs to generate class constructors.
% 
% 1. Class Constructor Registration
% ctors can be registered as function handles. Registered ctors should
% accept a mfc.extract.IJitPropertyExtractor:
% 
% 

    properties (Access=private)
        constructors containers.Map;
        IoCContainer IoC.IContainerGetter = IoC.ContainerGetter.empty();
    end
    
    methods
        function this = MFactory(varargin)
            this.constructors = containers.Map();
            
            % configure input parser
            parser = inputParser();
            parser.CaseSensitive = false;
            parser.FunctionName = 'mfc.MFactory';
            addParameter(parser, 'IoCContainer', []);

            % parse input
            parse(parser, varargin{:});
            if ~isempty(parser.Results.IoCContainer)
                this.IoCContainer = parser.Results.IoCContainer;
            end
        end
    end
    
    methods
        function addConstructor(this, className, ctor)
        % Adds a constructor to generate instances of the type specified by
        % className.
        % addConstructor(factory, className, ctorClass):
        %   factory   - the MFactory object
        %   className - string scalar or character vector containing the
        %               name of the class to register ctor for
        %   ctorClass - implements mfc.IMCtor
        %
        % addConstructor(factory, className, func):
        %   factory   - the MFactory object
        %   className - string scalar or character vector containing the
        %               name of the class to register ctor for
        %   func      - function handle with the following symbol:
        %               function instance = functionName(extractor)
        %                   where instance is the instance of the class and
        %                   extractor implements the
        %                   mfc.extract.IJitPropertyExtractor interface
        %
        % addConstructor(factory, className, funcName):
        %   factory   - the MFactory object
        %   className - string scalar or character vector containing the
        %               name of the class to register ctor for
        %   funcName  - the name of a function with the following symbol:
        %               function instance = functionName(extractor)
        %                   where instance is the instance of the class and
        %                   extractor implements the
        %                   mfc.extract.IJitPropertyExtractor interface
        
            if isa(ctor, 'mfc.IMCtor')
                mctor = ctor;
            else
                mctor = mfc.FunctionHandleCtor(className, ctor);
            end
            this.constructors(className) = mctor;
        end
        
        function instance = construct(this, className, varargin)
        % Creates an instance of the type specified by className
        % instance = construct(factory, className):
        %   factory   - the MFactory object
        %   className - string scalar or character vector containing the
        %               name of the class to register ctor for
        % Constructs the class specified by clssName without setting any of
        % its properties, unless default values are described
        %
        % instance = construct(factory, className, extractor):
        %   factory   - the MFactory object
        %   className - string scalar or character vector containing the
        %               name of the class to register ctor for
        %   extractor - implements mfc.extract.IJitPropertyExtractor. Used
        %               to extract fields to inject to the class
        % Constructs the class specified by clssName setting all property
        % values available in the extractor
        %
        % instance = construct(factory, className, obj):
        %   factory   - the MFactory object
        %   className - string scalar or character vector containing the
        %               name of the class to register ctor for
        %   obj       - a struct or object to copy the fields from
        % Constructs the class specified by clssName cloning all properties
        % from obj
        % instance = construct(factory, className, [name, value]):
        %   factory   - the MFactory object
        %   className - string scalar or character vector containing the
        %               name of the class to register ctor for
        %   [name, value] - a list of name-value pairs specifing the values
        %                   for the instance proeprties
        % Constructs the class specified by clssName cloning all properties
        % from obj
            
            % prepare property extraction method
            if numel(varargin) == 1
                if isa(varargin{1}, 'mfc.extract.IJitPropertyExtractor')
                    extractor = varargin{1};
                else
                    extractor = mfc.extract.StructJitExtractor(varargin{1});
                end
            else
                extractor = mfc.extract.NameValueJitExtractor(varargin);
            end
        
            if this.constructors.isKey(className)
                ctor = this.constructors(className);
                instance = ctor.build(extractor);
            else
                ctor = this.generateDefaultCtor(className);
                
                try
                    instance = ctor.build(extractor);
                catch ex
                    if strcmp(ex.identifier, 'mfc:MFactory:InvalidGenericCtor')
                        rethrow(ex);
                    end
                    
                    ex2 = MException('mfc:MFactory:InvalidGenericCtor', 'Failed to construct class %s. Check ctor definitions or implement mfc.IDescriptor for handle classes or mfc.IDescriptorStruct for non-handle classes.', className);
                    ex2 = addCause(ex2, ex);
                    ex2.throw();
                end

                this.addConstructor(className, ctor);
            end
        end
        
        function instance = constructEmptyArray(this, className)
        % Creates an empty vector of the type specified by className
            instance = feval([className '.empty']);
        end
        
        function tf = hasCtor(this, className)
        % Determines whether a ctor was already registered for the
        % specified class
            tf = this.constructors.isKey(className);
        end
        
        function reset(this)
        % Clears all constructors from the factory.
        % Use this if you need the factory to reevaluate mfc.IDescriptor 
        % and mfc.IDescriptorStruct
        % classes
            this.constructors.remove(this.constructors.keys);
        end
    end
    
    methods (Hidden)
        function instance = cunstructEmpty(this, className, varargin)
        % Obsolete...
            warning('MFactory.cunstructEmptyInstance is obsolete');
            if nargin >= 3
                data = varargin;
            else
                mc = meta.class.fromName(className);
                
                if mc.Enumeration
                    data = mc.EnumerationMemberList(1).Name;
                else
                    data = struct;
                    for propIdx = 1:length(mc.PropertyList)
                       data.(mc.PropertyList(propIdx).Name) = [];
                    end
                end
            end
            instance = this.construct(className, data);
            for currField = fieldnames(instance)'
                instance.(currField{1}) = [];
            end
        end
    end
    
    methods (Access=private)
        
        function ctor = generateDefaultCtor(this, className)
            % Try to dynamically generate a ctor for that class
            mc = meta.class.fromName(className);
            if mc.Enumeration
                ctor = mfc.EnumCtor(className);
            else
                ctor = mfc.ClassAnalyzerCtor(className, this.IoCContainer);
            end
        end
        
    end
end