classdef JsonSerializer < mxml.ISerializer & mfc.IDescriptor
% mxml.JsonSerializer is used to serialize/deserialize complete object graphs
% into/from json format files/strings
% The json produced by mxml.JsonSerializer is type specific, i.e., after
% deserializing the original type is maintained.
% Primitive types (numeric, char, string, logical) are not maintained by
% default, but the mxml.JsonSerializer can be configured to maintain
% primitive types as well using the MaintainAllTypes and MaintainedTypes
% properties.
% mxml.JsonSerializer uses the mfc ("Matlab Factory") package to generate
% class instances. If no factory is given to the mxml.JsonSerializer, it
% will use a new instance of mfc.MFactory. It is advised to pass a factory
% when creating mxml.JsonSerializer to prevent instantiation of a new
% mfc.MFactory for each serialized, which will affect performance, as 
% mfc.MFactory analyzes all non-registered classes on first use.

    properties (Constant, Access=protected)
        VERSION_PROP_NAME = 'mxmlSerializationVersion___';
        TYPE_PROP_NAME = 'mxmlSerializationType___';
        IS_LIST_PROP_NAME = 'mxmlSerializationIsList___';
        
        DefaultMaintainedTypes string = [];
    end
    
    methods
        function this = JsonSerializer(varargin)
            this@mxml.ISerializer(varargin{:});
        end
        
        function save(this, obj, path)
            json = this.serialize(obj);
            
            fid = [];
            try
                fid = fopen(path, 'w');
                fwrite(fid, json);
                fclose(fid);
            catch ex
                if ~isempty(fid) && ismember(fid, fopen('all'))
                    try
                        fclose(fid);
                    catch
                        % there is pretty much nothing else we can do about
                        % it now...
                    end
                end
                rethrow(ex);
            end
        end
        
        function obj = load(this, path)
            json = fileread(path);
            obj = this.deserialize(json);
        end
        
        function json = serialize(this, obj)
            jsonReady = this.jsonize(obj);
            jsonReady.(this.VERSION_PROP_NAME) = this.Version;
            json = jsonencode(jsonReady);
        end
        
        function obj = deserialize(this, json)
            element = jsondecode(json);
            if isfield(element, this.VERSION_PROP_NAME)
                version = element.(this.VERSION_PROP_NAME);
            else
                version = this.CompatibilityVersion;
            end
            
            if version == this.CompatibilityVersion
                obj = parsejsonElement(element);
            else
                obj = this.dejsonize(element, version);
            end
        end
    end
    
    methods (Access={?mxml.JsonFieldExtractor, ?mxml.JsonSerializer})
        function obj = dejsonize(this, element, version)
        % unravels a jsonized object, generating instances of the correct
        % classes for all fields down the object hierarchy
        
            % strings and cellstrings and primitive types
            if iscellstr(element) || isstring(element) || this.isPrimitiveValue(element)
                if size(element, 1) > 1 && size(element, 2) == 1
                    obj = element';
                else
                    obj = element;
                end
            % cell arrays, collections & object lists
            elseif isstruct(element) && isfield(element, this.IS_LIST_PROP_NAME) && element.(this.IS_LIST_PROP_NAME)
                obj = this.dejsonizeList(element, version);
                return;
            % objects & structs
            elseif isstruct(element)
                % structs and jsonized structs
                if ~isfield(element, this.TYPE_PROP_NAME) || strcmp(element.(this.TYPE_PROP_NAME), 'struct')
                    obj = this.dejsonizeStruct(element, version);
                % jsonized primitive values
                elseif this.isPrimitiveType(element.(this.TYPE_PROP_NAME))
                    obj = this.dejsonizeValue(element, version);
                % objects
                else
                    type = element.(this.TYPE_PROP_NAME);
                    if this.isenumType(type)
                        extractor = mfc.extract.ValueJitExtractor(element.value);
                    else
                        extractor = mxml.JsonFieldExtractor(this, element);
                    end
                    
                    % build the object, send the extractor to the factory
                    % only the required fields will be dejsonized upon
                    % request from the factory
                    obj = this.Factory.construct(type, extractor);
                end
            % anything else
            else
                obj = element;
            end
        end
    end
    
    methods (Access=protected)
        function jsonReady = jsonize(this, obj)
        % prepares an onject to be encoded to JSON.
        % jsonized objects are type aware, i.e. metadata is saved alongside
        % the data, to be added into the JSON string.
        % jsonized objects can be later decoded from JSON to the original
        % data types.
            
            % If obj is a number or a string or some other primitive value type
            if isenum(obj)
                if numel(obj) > 1
                    jsonReady = struct(this.TYPE_PROP_NAME, class(obj), this.IS_LIST_PROP_NAME, true, 'value', {arrayfun(@char, obj, 'UniformOutput', false)});
                else
                    jsonReady = struct(this.TYPE_PROP_NAME, class(obj), 'value', char(obj));
                end
            elseif this.isPrimitiveValue(obj) || iscellstr(obj) || isstring(obj)
                type = class(obj);
                if this.isMaintainedType(type)
                    jsonReady = struct(this.TYPE_PROP_NAME, type, 'value', obj);
                else
                    jsonReady = obj;
                end
            % if obj is an array of reference types or structs
            elseif (isvector(obj) && numel(obj) > 1) || iscell(obj) || isa(obj, 'mcol.ICollection')
                arraySize = length(obj);
                jsonReady = struct(this.TYPE_PROP_NAME, class(obj), this.IS_LIST_PROP_NAME, true, 'value', {cell(1, arraySize)});
                for i = 1:arraySize
                    jsonReady.value{i} = this.jsonize(this.accessArray(obj, i));
                end
            % handle ref types and structs
            elseif ~isempty(obj)
                fields = fieldnames(obj);
                jsonReady = struct(this.TYPE_PROP_NAME, class(obj));

                % Append all properties
                for i = 1:numel(fields)
                    currFieldName = fields{i};
                    fieldValue = obj.(currFieldName);
                    if isempty(fieldValue)
                        continue;
                    end
                    jsonReady.(currFieldName) = this.jsonize(fieldValue);
                end
            end
        end
    end
    
    methods (Access=private)
        function obj = dejsonizeList(this, element, version)
            n = numel(element.value);
            obj = createList(element.(this.TYPE_PROP_NAME), n);
            for i = 1:n
                inner = this.dejsonize(this.accessArray(element.value, i), version);
                if iscell(obj)
                    obj{i} = inner;
                elseif isa(obj, 'mcol.ICollection')
                    if obj.isempty()
                        obj.setVector(inner);
                    else
                        obj.set(i, inner);
                    end
                else
                    obj(i) = inner;
                end
            end
        end
        
        function obj = dejsonizeValue(this, element, version)
            if isstruct(element)
                converter = str2func(element.(this.TYPE_PROP_NAME));
                obj = converter(element.value);
            else
                obj = element;
            end
        end
        
        function obj = dejsonizeStruct(this, element, version)
            obj = struct();
            copyfrom = element;
            
            % Parse child fields recursively
            jsonFields = fieldnames(copyfrom);
            for fieldIdx = 1:numel(jsonFields)
                currField = jsonFields{fieldIdx};
                if ismember(currField, {this.TYPE_PROP_NAME, this.IS_LIST_PROP_NAME})
                    continue;
                end
                currItem = copyfrom.(currField);
                obj.(currField) = this.dejsonize(currItem, version);
            end
        end
    end
end

