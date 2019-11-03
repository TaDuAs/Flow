classdef (Abstract) ISerializer < handle & matlab.mixin.Heterogeneous
    properties (Constant)
        Version = 3;
        CompatibilityVersion = 2;
    end
    
    properties
        Factory mfc.IFactory = mfc.MFactory.empty();
        
        % MaintainedTypes determines whether this mxml.JsonSerializer
        % should serialize all data types into jsonized objects, including
        % primitive types such as double, char, string, etc.
        MaintainAllTypes (1,1) logical = false;
        
        % MaintainedTypes is a list of primitive type names to be
        % serialized as jsonized objects to allow backwards type
        % specificity for these types
        MaintainedTypes string;
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
        function tf = isMaintainedType(this, type)
            tf = this.MaintainAllTypes || ismember(type, this.MaintainedTypes) || ~this.isPrimitiveType(type);
        end
        
        function tf = isPrimitiveValue(this, value)
            tf = false;

            if isnumeric(value) ||... % numeric values are value type
               ischar(value) ||... % characters are value types
               islogical(value) ||... % booleans are value types
               isstring(value) % strings are value types
                tf = true;
            end
        end
        
        function tf = isPrimitiveType(this, type)
            mc = meta.class.fromName(type);
            if ~isempty(mc) && (mc.Abstract || mc.Enumeration || mc.HandleCompatible)
                tf = false;
            else
                x = feval([type '.empty']);
                tf = this.isPrimitiveValue(x);
            end
        end
        
        function item = accessArray(this, arr, i)
            if iscell(arr)
                item = arr{i};
            elseif isa(arr, 'mxml.ICollection')
                item = arr.get(i);
            else
                item = arr(i);
            end
        end
        
        function list = createList(this, type, n)
            if strcmp(type, 'cell')
                list = cell(1, n);
            elseif any(strcmp(superclasses(type), 'mxml.ICollection'))
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
            addParameter(parser, 'Factory', mfc.MFactory(),...
                @(x) assert(isa(x, 'mfc.IFactory'), 'Factory must implement the mfc.IFactory interface'));
            addParameter(parser, 'MaintainAllTypes', false,...
                @(x) assert(islogical(x) && isscalar(x), 'MaintainAllTypes must be a logical scalar'));
            addParameter(parser, 'MaintainedTypes', false,...
                @(x) assert(ischar(x) || isstring(x) || iscellstr(x), 'MaintainedTypes must be a list of type names to be maintained in json format'));
            
            % parse input
            parse(parser, args{:});
            
            % extract all parsed parameters
            this.Factory = parser.Results.Factory;
            this.MaintainAllTypes = parser.Results.MaintainAllTypes;
            this.MaintainedTypes = string(parser.Results.MaintainedTypes);
        end
        
        function tf = isCompatibilityMode(this, version)
            tf = version == this.CompatibilityVersion;
        end
    end
end

