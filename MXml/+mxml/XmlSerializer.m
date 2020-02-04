classdef XmlSerializer < mxml.ISerializer & mxml.IXmlInterpreter
    
    properties (Access=private, Constant)
        VERSION_ATTR_NAME = '_version';
        TYPE_ATTR_NAME = '_type';
        IS_LIST_ATTR_NAME = '_isList';
        LIST_ENRTY_TAG_NAME = '_entry';
        COMPATIBILITY_ELEMENT_NAMES = struct('TYPE_ATTR_NAME', 'type', 'IS_LIST_ATTR_NAME', 'isList', 'LIST_ENRTY_TAG_NAME', 'entry');
    end
    
    properties (Access=protected, Constant)
        DefaultMaintainedTypes string = ["double", "single", "logical", "int8", "int16", "int32", "int64", "uint8", "uint16", "uint32", "uint64"];
    end
    
    methods
        function this = XmlSerializer(varargin)
            this@mxml.ISerializer(varargin{:});
            
            % The default xml field extractor - mxml.XmlFieldExtractor 
            % generated by this builder is used during deserialization.
            % This property injection is for mocking the extractor during
            % unit tests: 
            this.ExtractorBuilder = mxml.XmlFieldExtractorBuilder();
        end
        
        function save(this, obj, path)
            dom = this.buildDOM(obj);
            xmlwrite(path, dom);
        end
        
        function obj = load(this, path)
            dom = xmlread(path);
            obj = this.interpretDOM(dom);
        end
        
        function xml = serialize(this, obj)
            dom = this.buildDOM(obj);
            xml = xmlwrite(dom);
        end
        
        function obj = deserialize(this, str)
            dom = mxml.xml2dom(str);
            obj = this.interpretDOM(dom);
        end
    end
    
    methods (Hidden)
        function obj = interpretElement(this, node, version)
            metadata = this.getMetaData(node, version);
            type = metadata.type;
            isList = metadata.isList;
            
            % interpret current element according to the meta-type
            if strcmp(type, 'char')
                if isList
                    cellValue = this.interpretCellArray(node, version);
                    obj = vertcat(cellValue{:});
                else
                    obj = char(node.getTextContent());
                end
            elseif strcmp(type, 'string')
                if isList
                    cellValue = this.interpretCellArray(node, version);
                    obj = string(cellValue);
                else
                    obj = string(node.getTextContent());
                end
            elseif this.isPrimitiveType(type)
                obj = mxml.converters.str2data(char(node.getTextContent()), type);
            elseif strcmp(type, 'cell')
                obj = this.interpretCellArray(node, version);
            elseif strcmp(type, 'struct')
                if isList
                    objCell = this.interpretCellArray(node, version);
                    obj = [objCell{:}];
                else
                    obj = struct();
                    [reservedAttrNames, reservedElemNames] = this.getReservedMetadataAttributeNames(version, false);
                    extractor = this.ExtractorBuilder.build(this, node, version, reservedAttrNames, reservedElemNames);
                    allFields = extractor.allProps();

                    % import all fields into the struct
                    for i = 1:numel(allFields)
                        currProp = allFields{i};
                        if extractor.hasProp(currProp)
                            obj.(currProp) = extractor.get(currProp);
                        end
                    end
                end
            else
                typeMC = meta.class.fromName(type);
                
                % if implements lists.ICollection
                if typeMC <= ?lists.ICollection
                    % generate the list object - extract its data from xml
                    [reservedAttrNames, reservedElemNames] = this.getReservedMetadataAttributeNames(version, true);
                    extractor = this.ExtractorBuilder.build(this, node, version, reservedAttrNames, reservedElemNames);
                    obj = this.Factory.construct(type, extractor);
                    
                    % generate the list items and inject into the list
                    % object
                    valueArr = this.interpretClassArray(node, version);
                    obj.setVector(valueArr);
                elseif isList
                    obj = this.interpretClassArray(node, version);
                else
                    % Generate dynamic object
                    [reservedAttrNames, reservedElemNames] = this.getReservedMetadataAttributeNames(version, false);
                    extractor = this.ExtractorBuilder.build(this, node, version, reservedAttrNames, reservedElemNames);
                    obj = this.Factory.construct(type, extractor);
                end
            end
        end
        
        function obj = interpretAttribute(this, attr, version)
            obj = char(attr);
        end
        
    end
    methods (Access=protected)
        function value = interpretCellArray(this, node, version)
            children = node.getChildNodes();
            n = children.getLength();
            valueCell = cell(1,n);
            validValuesMask = false(1,n);
            
            if this.isCompatibilityMode(version)
                entryElementNodeName = this.COMPATIBILITY_ELEMENT_NAMES.LIST_ENRTY_TAG_NAME;
            else
                entryElementNodeName = this.LIST_ENRTY_TAG_NAME;
            end
            
            % iterate through all xml elements
            for i = 1:n
                currEntry = children.item(i-1);
                
                % only parse actual elements, no text nodes, comments, etc.
                if currEntry.getNodeType() == currEntry.ELEMENT_NODE && strcmp(char(currEntry.getNodeName()), entryElementNodeName)
                    valueCell{i} = this.interpretElement(currEntry, version);
                    validValuesMask(i) = true;
                end
            end
            
            % trim non interpreted items from the array
            value = valueCell(validValuesMask);
        end
        
        function value = interpretClassArray(this, node, version)
            valueCell = this.interpretCellArray(node, version);
            
            % change to row vector
            value = [valueCell{:}];
        end
        
        function obj = interpretDOM(this, dom)
            if ~dom.hasChildNodes()
                obj = [];
            else
                document = dom.getDocumentElement();
                if document.hasAttribute(this.VERSION_ATTR_NAME)
                    version = str2double(document.getAttribute(this.VERSION_ATTR_NAME));
                else
                    % if version attribute is missing, use compatibility
                    % mode
                    version = this.CompatibilityVersion;
                end
                obj = this.interpretElement(document, version);
            end
        end
        
        function [element, document] = buildDOM(this, obj, tagName, document, parentElement, forceMaintainType)
            % validate valid datatypes
            if istable(obj) || isa(obj, 'containers.Map')
                error('tables and maps are not supported by this function yet... if your getting this, better implement it quick!');
            end
            
            % defaults
            if nargin < 6; forceMaintainType = false; end
            
            % Set data type
            type = class(obj);
            maintainType = forceMaintainType ||... % if calling function requires this item to be type-maintained
                this.isMaintainedType(type) ||... % check maintained types
                (~isscalar(obj) && ~ischar(obj)) || ... % non-character vectors shouldn't be saved in attributes
                ~isrow(obj); % character matrices shouldn't be saved in attributes
            
            % If no document is specified, generate one and treat this object as
            % the root
            if nargin < 4 || isempty(document)
                % if this is the root, and no tag name was specified,
                % use the default root tag - <document>
                if nargin < 3 || isempty(tagName)
                    tagName = 'document';
                end

                % Generate DOM object and root element
                document = com.mathworks.xml.XMLUtils.createDocument(tagName);
                parentElement = document.getDocumentElement;
                element = parentElement;
                element.setAttribute(this.TYPE_ATTR_NAME, type);
                element.setAttribute(this.VERSION_ATTR_NAME, num2str(this.Version));
                
                % always maintain the type of the root object
                maintainType = true;
            elseif ~maintainType && ~isempty(obj)
                element = parentElement;
            elseif ~isempty(obj)
                element = document.createElement(tagName);
                element.setAttribute(this.TYPE_ATTR_NAME, type);
                parentElement.appendChild(element);
            end
            
            if isempty(obj)
                return;
            end
            
            % If obj is a number or a string or some other primitive value type
            if isenum(obj) || this.isPrimitiveValue(obj)
                % convert data to string format
                if isenum(obj)
                    value = char(obj);
                elseif isnumeric(obj) || islogical(obj)
                    value = mxml.converters.mat2str(obj);
                elseif ischar(obj)
                    if ~isrow(obj) && ismatrix(obj)
                        element.setAttribute(this.IS_LIST_ATTR_NAME, 'true');
                        for i = 1:size(obj,1)
                            this.buildDOM(obj(i,:), this.LIST_ENRTY_TAG_NAME, document, element, true);
                        end
                        return;
                    else
                        value = obj;
                    end
                else 
                    % strings
                    if numel(obj) > 1
                        element.setAttribute(this.IS_LIST_ATTR_NAME, 'true');
                        for i = 1:length(obj)
                            this.buildDOM(obj(i), this.LIST_ENRTY_TAG_NAME, document, element, true);
                        end
                        return;
                    else
                        value = obj;
                    end
                end
                
                % if the type of obj should be maintained after
                % serialization and deserialization cycles, make it a full
                % element with the _type attribute and all the rest
                if maintainType
                    valueNode = document.createTextNode(value);
                    element.appendChild(valueNode);
                % otherwise, make it an attribute
                else
                    element.setAttribute(tagName, value);
                end
            % if obj is an array of reference types or structs
            elseif ~isscalar(obj) || iscell(obj) || isa(obj, 'lists.ICollection')
                element.setAttribute(this.IS_LIST_ATTR_NAME, 'true');
                for i = 1:length(obj)
                    this.buildDOM(this.accessArray(obj, i), this.LIST_ENRTY_TAG_NAME, document, element, true);
                end
            % handle ref types and structs
            elseif ~isempty(obj)
                fields = fieldnames(obj);

                % Append all properties
                for i = 1:length(fields)
                    fieldName = fields{i};
                    fieldValue = obj.(fieldName);
                    this.buildDOM(fieldValue, fieldName, document, element);
                end
            end
        end

        function md = getMetaData(this, node, version)
            md.type = 'struct';
            
            % use the correct attributes
            elementNames = this;
            if this.isCompatibilityMode(version)
                elementNames = this.COMPATIBILITY_ELEMENT_NAMES;
            end
            
            % determine object type
            if node.hasAttribute(elementNames.TYPE_ATTR_NAME)
                md.type = char(node.getAttribute(elementNames.TYPE_ATTR_NAME));
            end
            
            % if object is a list
            md.isList = false;
            if node.hasAttribute(elementNames.IS_LIST_ATTR_NAME)
                md.isList = mxml.converters.str2boolean(char(node.getAttribute(elementNames.IS_LIST_ATTR_NAME)));
            end
        end
    end
    
    methods (Access=private)
        function [attrNames, elemNames] = getReservedMetadataAttributeNames(this, version, isList)
            if this.isCompatibilityMode(version)
                % compatibility mode attributes
                attrNames = {this.COMPATIBILITY_ELEMENT_NAMES.TYPE_ATTR_NAME, this.COMPATIBILITY_ELEMENT_NAMES.IS_LIST_ATTR_NAME};
                if isList
                    elemNames = {this.COMPATIBILITY_ELEMENT_NAMES.LIST_ENRTY_TAG_NAME};
                else
                    elemNames = {};
                end
            else
                % regular meta data attributes
                attrNames = {this.VERSION_ATTR_NAME, this.TYPE_ATTR_NAME, this.IS_LIST_ATTR_NAME};
                
                % the _entry tag name is always reserved, there can be no
                % property with the name _entry
                elemNames = {this.LIST_ENRTY_TAG_NAME};
            end
        end
    end
end

