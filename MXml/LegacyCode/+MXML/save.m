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

    if nargin < 1 || isempty(fileName)
        error('Must specify file name');
    end
    if nargin == 3 && ischar(meta) && (strcmp(meta, 'json') || strcmp(meta, 'xml'))
        format = meta;
        meta = [];
    elseif nargin < 4
        format = '';
    end
    serializer = MXML.generateDefaultSerializer();
    
    % Write all meta data fields as attributes on the root element
    if nargin >= 3 && ~isempty(meta); obj.meta = meta; end

    % Write all data entries as child nodes of the root element
    if nargin >= 2; obj.data = data; end
    
    % save to file
    serializer.save(obj, fileName);
    
    % Display xml document contents
    if nargin >= 5 && showFileContents
        type(fileName);
    end
end
