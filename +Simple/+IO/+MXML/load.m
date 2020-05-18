function [data, metadata] = load(fileName, format)
% loads data from a text file (xml/json) or from xml/json string.
% Data may contain all primitive values, including struct trees, as well as
% user defined classes as long as they allow for construction using empty 
% ctor or are registered in the Simple.IO.MXML.Factory class
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

    warning('Simple:IO:MXML', 'Don''t use the obsolete Simple packages');
    [data, metadata] = MXML.load(fileName, format);
end