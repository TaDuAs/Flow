classdef (Abstract) ISerializer < handle & matlab.mixin.Heterogeneous & mfc.IDescriptor
    properties (Constant)
        Version = 3;
        CompatibilityVersion = 2;
    end
    
    properties
        Factory mfc.IFactory = mfc.MFactory.empty();
        
        % Generates the relevant field extractors for the specific 
        % serializer implementation.
        % This class factory loosens the coupling between the serializer
        % and extractor to enable proper unit tests
        ExtractorBuilder mxml.IFieldExtractorBuilder = mxml.XmlFieldExtractorBuilder.empty();
        
        % MaintainedTypes determines whether this mxml.JsonSerializer
        % should serialize all data types into jsonized objects, including
        % primitive types such as double, char, string, etc.
        MaintainAllTypes (1,1) logical = false;
        
        % MaintainedTypes is a list of primitive type names to be
        % serialized as jsonized objects to allow backwards type
        % specificity for these types
        MaintainedTypes string;
    end
    
    properties (Abstract, Access=protected, Constant)
        DefaultMaintainedTypes string;
    end
    
    methods (Abstract)
        save(this, obj, path);
        obj = load(this, path);
        str = serialize(this, obj);
        obj = deserialize(this, str);
    end
    
    methods % metadata definitions
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'@Factory', 'Factory', '@MaintainAllTypes', 'MaintainAllTypes', '@MaintainedTypes', 'MaintainedTypes'};
            defaultValues = {};
        end
    end
    
    methods (Access=protected) % utilities
        function this = ISerializer(varargin)
            this.parseConfiguration(varargin);
        end
        
        function tf = isMaintainedType(this, type)
            tf = this.MaintainAllTypes || ismember(type, this.MaintainedTypes) || ~this.isPrimitiveType(type);
        end
        
        function tf = isPrimitiveValue(this, value)
            tf = gen.isPrimitiveValue(value);
        end
        
        function tf = isPrimitiveType(this, type)
            tf = gen.isPrimitiveType(type);
        end
        
        function item = accessArray(this, arr, i)
            if iscell(arr)
                item = arr{i};
            elseif isa(arr, 'lists.ICollection')
                item = arr.getv(i);
            else
                item = arr(i);
            end
        end
        
        function list = createList(this, type, n)
            if strcmp(type, 'cell')
                list = cell(1, n);
            elseif any(strcmp(superclasses(type), 'lists.ICollection'))
                list = this.Factory.construct(type);
            else
                list = repmat(this.Factory.cunstructEmpty(type), 1, n);
            end
        end
        
        function tf = isenumType(this, item)
            if ischar(item) || isStringScalar(item)
                mc = meta.class.fromName(item);
            else
                mc = metaclass(item);
            end
            
            tf = ~isempty(mc) && mc.Enumeration;
        end
        
        function parseConfiguration(this, args)
            % configure input parser
            parser = inputParser();
            parser.CaseSensitive = false;
            parser.FunctionName = class(this);
            
           	% define parameters
            addParameter(parser, 'Factory', mfc.MFactory.empty(),...
                @(x) assert(isa(x, 'mfc.IFactory') && ~isempty(x), 'Factory must implement the mfc.IFactory interface'));
            addParameter(parser, 'MaintainAllTypes', false,...
                @(x) assert(islogical(x) && isscalar(x), 'MaintainAllTypes must be a logical scalar'));
            addParameter(parser, 'MaintainedTypes', this.DefaultMaintainedTypes,...
                @(x) assert(ischar(x) || isstring(x) || iscellstr(x), 'MaintainedTypes must be a list of type names to be maintained in json format'));
            
            % parse input
            parse(parser, args{:});
            
            % extract all parsed parameters
            if ~isempty(parser.Results.Factory)
                this.Factory = parser.Results.Factory;
            else
                this.Factory = mfc.MFactory();
            end
            this.MaintainAllTypes = parser.Results.MaintainAllTypes;
            this.MaintainedTypes = string(parser.Results.MaintainedTypes);
        end
        
        function tf = isCompatibilityMode(this, version)
            tf = version == this.CompatibilityVersion;
        end
    end
end

