classdef FileFormatSerializer < mxml.ISerializer
    % One Serialzer to serialize them all, One Serializer to save them,
    % One Serialzer to deserialize them all and from a text file Load them.
    %
    % mxml.FileFormatSerializer uses mxml.ISerializer registered to
    % given file formats
    
    properties
        Formats string;
        Serializers mxml.ISerializer = mxml.XmlSerializer.empty();
    end
    
    methods
        function this = FileFormatSerializer(fileFormats, serializers, varargin)
            this@mxml.ISerializer(varargin{:});
            
            this.Formats = fileFormats;
            this.Serializers = serializers;
        end
        
        function ser = getSerializer(this, format)
            [tf, i] = ismember(lower(format), lower(this.Formats));
            if ~tf
                throw(MException('mxml:FileFormatSerializer:formatNotAvailable', 'Format %s is not available for this mxml.FileFormatSerializer', format));
            end
            
            ser = this.Serializers(i);
        end
        function format = getFormatFromFile(this, path)
            [~, ~, format] = fileparts(path);
            format = regexprep(format, '^\.', '');
        end
        
        function save(this, obj, path, format)
            if nargin < 4 || isempty(format)
                format = this.getFormatFromFile(path);
            end
            
            ser = this.getSerializer(format);
            ser.save(obj, path);
        end
        function obj = load(this, path, format)
            if nargin < 4 || isempty(format)
                format = this.getFormatFromFile(path);
            end
            
            ser = this.getSerializer(format);
            obj = ser.load(path);
        end
        function str = serialize(this, obj, format)
            if nargin < 4 || isempty(format)
                format = this.Formats(1);
            end
            
            ser = this.getSerializer(format);
            str = ser.serialize(obj);
        end
        function obj = deserialize(this, str, format)
            if nargin < 4 || isempty(format)
                format = this.Formats(1);
            end
            
            ser = this.getSerializer(format);
            obj = ser.deserialize(str);
        end
    end
end

