function save(fileName, data, meta, format, showFileContents)
% Saves a data array of structs\classes as an xml/json document
% 
% mxml.legacy.save('filePath/fileName.xml', data, [meta])
%           saves to xml formatted file
% mxml.legacy.save('filePath/fileName.json', data, [meta])
%           saves to json formatted file
% mxml.legacy.save('filePath/fileName.notXmlNorJson', data, [meta])
%           saves to xml formatted file
% mxml.legacy.save(filename, data, format)
%           saves to file according to specified format ('xml' or 'json')
% mxml.legacy.save(filename, data, meta, format)
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
        switch lower(fileName(find(fileName == '.', 1, 'last') + 1:end))
            case 'json'
                format = 'json';
            otherwise
                format = 'xml';
        end
    end
    
    % Write all meta data fields as attributes on the root element
    if nargin >= 3 && ~isempty(meta); obj.meta = meta; end

    % Write all data entries as child nodes of the root element
    if nargin >= 2; obj.data = data; end
    
    switch format
        case 'xml'
            % Export everything to XML document
            [~, document] = serialize(obj, [], [], []);

            % Write xml document
            xmlwrite(fileName, document);
        case 'json'
            % Export everything to XML document
            jsonElement = jsonize(obj);

            % serialize to json format
            json = jsonencode(jsonElement);

            % Write xml document
            fid = fopen(fileName, 'w');
            fwrite(fid, json);
            fclose(fid);
        otherwise
            throw(MException('MXML:save:formatNotSupported', sprintf('Format %s not supported', format)));
    end
    
    % Display xml document contents
    if nargin >= 5 && showFileContents
        type(fileName);
    end
end
