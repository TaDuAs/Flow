classdef JsonFieldExtractor < mfc.extract.IJitPropertyExtractor
    % Extracts dejsonized data from jsonized data upon request
    % only the required fields are dejsonized, and only when requested
    
    properties
        Serializer mxml.JsonSerializer;
        Object;
    end
    
    methods
        function this = JsonFieldExtractor(serializer, obj)
            this.Serializer = serializer;
            this.Object = obj;
        end
        
        function tf = hasProp(this, property)
        % determines if the desired property exists in the data
            tf = isfield(this.Object, property);
        end
        
        function value = get(this, property)
        % gets the desired property from the data
            obj = this.Object.(property);
            value = this.Serializer.dejsonize(obj);
        end
    end
    
    methods (Hidden)
        function list = allProps(this)
        % Gets the full list of property names available in this extractor
            list = fieldnames(this.Object);
            metaDataFields = startsWith(list, 'mxmlSerialization') & endsWith(list, '___');
            list = list(~metaDataFields);
        end
    end
end

