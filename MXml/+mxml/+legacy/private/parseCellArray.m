function value = parseCellArray(element)
    value = {};
    for j = 1:length(element.Children)
        currEntry = element.Children(j);
        if ~isVirtualXMLNode(currEntry)
            value{length(value) + 1} = parseElement(currEntry);
        end
    end
end