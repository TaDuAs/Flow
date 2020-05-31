function value = parseVector(element)
    value = [];
    for j = 1:length(element.Children)
        currEntry = element.Children(j);
        if ~mxml.legacy.private.isVirtualXMLNode(currEntry)
            % Initialize the vector of the right data type, its
            % necessary unfortunately...
            if isempty(value)
                value = mxml.legacy.private.parseElement(currEntry);
            else
                value(length(value) + 1) = mxml.legacy.private.parseElement(currEntry);
            end
        end
    end
end