classdef (Abstract) IFieldExtractorBuilder
    methods (Abstract)
        extractor = build(this, varargin);
    end
end

