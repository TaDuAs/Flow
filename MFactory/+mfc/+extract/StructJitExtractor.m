classdef StructJitExtractor < mfc.extract.IJitPropertyExtractor
    %STRUCTJITEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Obj;
    end
    
    methods
        function this = StructJitExtractor(obj)
            this.Obj = obj;
        end
        
        function tf = hasProp(this, property)
        % determines if the desired property exists in the data
            tf = isfield(this.Obj, property) || isprop(this.Obj, property);
        end
        
        function value = get(this, property)
        % gets the desired property from the data
            value = this.Obj.(property);
        end
    end
    
    methods (Hidden)
        function list = allProps(this)
        % Gets the full list of property names available in this extractor
            list = fieldnames(this.Obj);
        end
    end
end

