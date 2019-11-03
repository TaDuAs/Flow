function [element, document] = serialize(obj, tagName, document, parentElement)
    % validate valid datatypes
    if istable(obj) || isa(obj, 'containers.Map')
        error('tables and maps are not supported by this function yet... if your getting this, better implement it quick!');
    end

    % If no document is specified, generate one and treat this object as
    % the root
    if ~exist('document', 'var') || isempty(document)
        % if this is the root, and no tag name was specified,
        % use the default root tag - <document>
        if ~exist('tagName', 'var') || isempty(tagName)
            tagName = 'document';
        end
        
        % Generate DOM object and root element
        document = com.mathworks.xml.XMLUtils.createDocument(tagName);
        parentElement = document.getDocumentElement;
        element = parentElement;
    else
        element = document.createElement(tagName);
        parentElement.appendChild(element);
    end

    % Set data type
    element.setAttribute('type', class(obj));
    
    % If obj is a number or a string or some other primitive value type
    if isenum(obj) && length(obj) < 2
        % currently doesn't support enum arrays
        value = char(obj);
        valueNode = document.createTextNode(value);
        element.appendChild(valueNode);
    elseif ~isenum(obj) && isPrimitiveValueType(obj)
        if isnumeric(obj) || islogical(obj)
            value = convertMat2str(obj);
        elseif ischar(obj)
            value = charmat2str(obj);
        end
        try
        valueNode = document.createTextNode(value);
        element.appendChild(valueNode);
        catch e
            disp(e);
        end
    % if obj is an array of reference types or structs
    elseif (isvector(obj) && length(obj) > 1) || iscell(obj)
        element.setAttribute('isList', 'true');
        for i = 1:length(obj)
            serialize(accessArray(obj, i), 'entry', document, element);
        end
    % handle ref types and structs
    elseif ~isempty(obj)
        fields = fieldnames(obj);
        
        % Append all properties
        for i = 1:length(fields)
            fieldName = fields{i};
            fieldValue = obj.(fieldName);
            serialize(fieldValue, fieldName, document, element);
        end
    end
end



