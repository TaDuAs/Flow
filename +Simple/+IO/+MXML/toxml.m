function xml = toxml(data, meta)
% Serializes a data array of structs\classes to xml string in the MXML
% format: <document type="struct"><data type="...">...</data><meta type="...">...</meta></document>
%
% xml = toxml([data, meta])
%
% Author: Tal Duanis-Assaf

    Simple.obsoleteWarning('Simple.IO.MXML');
    if nargin < 2; meta = []; end
    xml = MXML.toxml(data, meta);
    
end

