classdef XmlFieldExtractorBuilder < mxml.IFieldExtractorBuilder
    methods
        function extractor = build(this, interpreter, node, version, reservedAttributes, reservedElements)
            extractor = mxml.XmlFieldExtractor(interpreter, node, version, reservedAttributes, reservedElements);
        end
    end
end

