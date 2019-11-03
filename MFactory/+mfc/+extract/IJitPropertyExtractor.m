classdef (Abstract) IJitPropertyExtractor < handle
    % MFactory.IJitPropertyExtractor is an interface for just-in-time
    % property extraction from data for the purpose of object construction
    
    methods (Abstract)
        % determines if the desired property exists in the data
        tf = hasProp(this, property);
        
        % gets the desired property from the data
        value = get(this, property);
    end
    
    methods (Abstract, Hidden)
        % Gets the full list of property names available in this extractor
        list = allProps(this);
    end
end

