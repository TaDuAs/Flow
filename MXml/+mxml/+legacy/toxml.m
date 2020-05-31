function xml = toxml(data, meta)
% Serializes a data array of structs\classes to xml string in the MXML
% format: <document type="struct"><data type="...">...</data><meta type="...">...</meta></document>
%
% xml = toxml([data, meta])
%
% Author: Tal Duanis-Assaf
    if exist('meta', 'var')
        obj.meta = meta;
    end

    % Write all data entries as child nodes of the root element
    if exist('data', 'var')
        obj.data = data;
    end
    
    % Export everything to XML document
    [~, document] = mxml.legacy.private.serialize(obj);
    
    % Write xml document
    xml = xmlwrite(document);
    
end

