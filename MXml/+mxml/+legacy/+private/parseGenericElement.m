function value = parseGenericElement(element, dataType)
    value = struct();

    % Dynamically add properties to the struct according to the child
    % nodes of the XML element
    childNodesNum = length(element.Children);
    fieldsNum = 0;
    for j = 1:childNodesNum
        currField = element.Children(j);
        [fieldData, empty] = mxml.legacy.private.parseElement(currField);
        if ~empty
            value.(currField.Name) = fieldData;
            fieldsNum = fieldsNum + 1;
        end
    end

    % If no proper child node fields exist, find the first text node
    % and return the data inside
    % If no such data node exists, return empty struct
    if fieldsNum == 0 && ~strcmp(dataType, 'struct')
        for j = 1:childNodesNum
            currChildNode = element.Children(j);
            if mxml.legacy.private.isTextXMLNode(currChildNode)
                value = currChildNode.Data;
            end
        end
    end
end
