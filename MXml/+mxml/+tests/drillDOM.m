function root = drillDOM(node)
    root.node = node;
    root.name = char(node.getTagName());
    root.attr = struct();
    root.children = struct();
    root.list = {};
    
    attr = node.getAttributes();
    for i = 0:attr.getLength()-1
        curr = attr.item(i);
        name = char(curr.getName());
        root.attr.(regexprep(name, '^_', 'a_')) = struct('name', name, 'value', char(curr.getValue()), 'node', curr);
    end
    
    children = node.getChildNodes();
    for i = 0:children.getLength()-1
        curr = children.item(i);
        
        switch curr.getNodeType()
            case [curr.COMMENT_NODE, curr.ATTRIBUTE_NODE]
                continue;
            case curr.TEXT_NODE
                if children.getLength() == 1
                    root.value = char(curr.getData);
                    break;
                else
                    continue;
                end
            otherwise
                name = char(curr.getTagName());
                attributes = fieldnames(root.attr);
                isList = false;
                if ismember('a_isList', attributes)
                    isList = any(strcmpi(root.attr.a_isList.value, {'true', '1'}));
                elseif ismember('isList', attributes)
                    isList = any(strcmpi(root.attr.isList.value, {'true', '1'}));
                end
                
                currChild = mxml.tests.drillDOM(curr);
                if isList && strcmp(name, '_entry')
                    root.list{numel(root.list)+1} = currChild;
                else
                    root.children.(name) = currChild;
                end
        end
    end
end