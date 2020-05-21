function save(fileName, data, meta, format, showFileContents)
% Saves a data array of structs\classes as an xml/json document
% 
% Simple.IO.MXML.save('filePath/fileName.xml', data, [meta])
%           saves to xml formatted file
% Simple.IO.MXML.save('filePath/fileName.json', data, [meta])
%           saves to json formatted file
% Simple.IO.MXML.save('filePath/fileName.notXmlNorJson', data, [meta])
%           saves to xml formatted file
% Simple.IO.MXML.save(filename, data, format)
%           saves to file according to specified format ('xml' or 'json')
% Simple.IO.MXML.save(filename, data, meta, format)
%           saves to file according to specified format ('xml' or 'json')
%
% Author: TADA
    Simple.obsoleteWarning('Simple.IO.MXML');
    if nargin < 3; meta = []; end
    if nargin < 4; format = ''; end
    if nargin < 5; showFileContents = false; end
    MXML.save(fileName, data, meta, format, showFileContents);
end
