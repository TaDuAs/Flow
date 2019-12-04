function [data, metadata] = load(fileName, format)
% loads data from a text file (xml/json) or from xml/json string.
% Data may contain all primitive values, including struct trees, as well as
% user defined classes as long as they allow for construction using empty 
% ctor or are registered in the mxml.legacy.Factory class
% 
% [data, metadata] = load('filePath/fileName.xml') - loads xml formatted file
% [data, metadata] = load('filePath/fileName.json') - loads json formatted file
% [data, metadata] = load('filePath/fileName.notXmlNorJson') - loads xml formatted file
% [data, metadata] = load(filename, format) - loads from file according to specified format ('xml' or 'json')
% [data, metadata] = load(xmlString, 'xml') - loads from xml string
% [data, metadata] = load(jsonString, 'json') - loads from json string
%
% Not implemented yet: tables, containers.Map, string matrix
% In json format, numeric, and character arrays / strings are not
% reversibly loaded from file, because that the format doesn't save the
% type for these primitive types to minimize file size/performance overhead 
% of rebuilding the object graph and wrapping in structs for all data types
% Therefore, all strings/character arrays are loaded as character arrays 
% and all numeric values are loaded as double.
% 
% Author: TADA
    if nargin < 2
        switch lower(fileName(find(fileName == '.', 1, 'last') + 1:end))
            case 'json'
                format = 'json';
            otherwise
                format = 'xml';
        end
    end
    
    if nargout > 1
        metadata = struct();
    end
    
    switch format
        case 'xml'
            dom = parse(fileName);
            for i = 1:length(dom.Children)
                if strcmp(dom.Children(i).Name, 'meta')
                    metadata = parseElement(dom.Children(i));
                elseif strcmp(dom.Children(i).Name, 'data')
                    data = parseElement(dom.Children(i));
                end
            end
        case 'json'
            obj = parsejson(fileName);
            if isfield(obj, 'data')
                data = obj.data;
                if isfield(obj, 'meta')
                    metadata = obj.meta;
                end
            else
                data = obj;
            end
        otherwise
            throw(MException('MXML:load:formatNotSupported', sprintf('Format %s not supported', format)));
    end
end