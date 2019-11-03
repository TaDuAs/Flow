classdef ValueJitExtractor < mfc.extract.IJitPropertyExtractor
    properties
        Value;
    end
    
    methods
        function this = ValueJitExtractor(value)
            this.Value = value;
        end
        
        function tf = hasProp(~, ~)
        % only has stored value, not fields and stuff
            tf = false;
        end
        
        function value = get(this, ~)
        % gets the stored value
            value = this.Value;
        end
    end
    
    methods (Hidden)
        function list = allProps(this)
        % Gets the full list of property names available in this extractor
            list = {};
        end
    end
end

