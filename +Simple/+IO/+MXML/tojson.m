function json = tojson(data, meta)
% Serializes a data array of structs\classes as a json string in the MXML
% format - ({"type":"struct","value":{"data":{...},"meta":{...}}}
%
% json = tojson([data, meta])
%
% Author: Tal Duanis-Assaf
    Simple.obsoleteWarning('Simple.IO.MXML');
    if nargin < 2; meta = []; end
    json = MXML.tojson(data, meta);
    
end

