% Determine if the specified element is a virtual node or a proper XML
% node in the DOM
% Virtual Nodes include Text Nodes, Comments etc.
function isVirtual = isVirtualXMLNode(element)
    isVirtual = any(regexp(element.Name, '^#'));
end