classdef XmlFieldExtractorBuilder < mxml.IFieldExtractorBuilder
    methods
        function extractor = build(this, interpreter, node, version, reservedAttributes)
            extractor = mxml.XmlFieldExtractor(interpreter, node, version, reservedAttributes);
        end
    end
end

