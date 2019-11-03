% Matlab's DOM holds virtual nodes for the textual data inside an
% element, this function determines whether a specified XML element is
% a text node
function isText = isTextXMLNode(element)
    isText = strcmp(element.Name, '#text');
end