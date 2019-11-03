classdef XmlFieldExtractor < mfc.extract.IJitPropertyExtractor
    %XMLFIELDEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Serializer mxml.XmlSerializer;
        Node;
        ChildNodes;
        ChildNodesIndices;
        Attributes;
        Version;
    end
    
    methods
        function this = XmlFieldExtractor(serializer, node, version)
            this.Serializer = serializer;
            this.Node = node;
            this.Version = version;
        end
        
        function tf = hasProp(this, property)
        % determines if the desired property exists in the data
            tf = this.hasAttr(property) || this.hasChild(property);
        end
        
        function value = get(this, property)
        % gets the desired property from the data
            if nargin < 2
                value = char(this.Node.getTextContent());
                return;
            end
            
            [hasChildProp, childNodeIndex] = this.hasChild(property);
            
            if hasChildProp
                children = this.Node.getChildNodes();
                node = children.item(childNodeIndex);
                value = this.Serializer.interpretElement(node, this.Version);
            elseif this.hasAttr(property)
                value = this.Serializer.interpretAttribute(this.Node.getAttribute(property), this.Version);
            else
                throw(MException('mxml:XmlFieldExtractor:MissingField', 'Can''t get value for field %s, as it is missing', property));
            end
        end
    end
    
    methods (Access=protected)
        function tf = hasAttr(this, name)
            tf = this.Node.hasAttribute(name);
        end
        
        function [tf, idx] = hasChild(this, name)
            this.investigateChildNodesFields();
            
            if nargout > 1
                [tf, i] = ismember(name, this.ChildNodes);
                if tf
                    idx = this.ChildNodesIndices(i);
                else
                    idx = [];
                end
            else
                tf = ismember(name, this.ChildNodes);
            end
        end
        
        function investigateChildNodesFields(this)
            if ~isempty(this.ChildNodes)
                return;
            end
            
            children = this.Node.getChildNodes();
            n = children.getLength();
            childNodesNames = cell(1, n);
            actualNodesMask = false(1, n);
            
            % iterate through all nodes
            for i = 1:n
                % get current xml node
                node = children.item(i-1);
                nodeType = node.getNodeType();
                
                % skip nodes that aren't actual xml elements: comments,
                % text nodes, etc.
                if nodeType ~= node.ELEMENT_NODE
                    continue;
                end
                
                % extract the name of actual nodes
                childNodesNames{i} = char(node.getNodeName());
                
                % mark node index as actual node
                actualNodesMask(i) = true;
            end
            
            this.ChildNodes = childNodesNames(actualNodesMask);
            this.ChildNodesIndices = find(actualNodesMask) - 1;
        end
    end
    
    methods (Hidden)
        function list = allProps(this)
        % Gets the full list of property names available in this extractor
            this.investigateChildNodesFields();
            
            attributeList = this.Node.getAttributes();
            nAttr = attributeList.getLength();
            attributeNameList = cell(1, nAttr);
            attrMask = false(1, nAttr);
            for i = 1:nAttr
                curr = attributeList.item(i-1);
                currAttrName = char(curr.getName());
                if ~startsWith(currAttrName, '_')
                    attributeNameList{i} = currAttrName;
                    attrMask(i) = true;
                end
            end
            list = [this.ChildNodes, attributeNameList(attrMask)];
        end
    end
end