function json = tojson(data, meta)
% Serializes a data array of structs\classes as a json string in the MXML
% format - ({"type":"struct","value":{"data":{...},"meta":{...}}}
%
% json = tojson([data, meta])
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
    jsonElement = jsonize(obj);
    
    % serialize to json format
    json = jsonencode(jsonElement);
    
end

