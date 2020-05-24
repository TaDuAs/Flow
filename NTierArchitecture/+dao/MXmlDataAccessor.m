classdef MXmlDataAccessor < dao.FileSystemDataAccessor & mfc.IDescriptor
    properties
        Serializer mxml.ISerializer = mxml.XmlSerializer.empty();
    end
    
    methods (Hidden) % meta data
        % provides initialization description for mfc.MFactory
        % ctorParams is a cell array which contains the parameters passed to
        % the ctor and which properties are to be set during construction
        % 
        % ctor dependency rules:
        %   Extract from fields:
        %       Parameter name is the name of the property, with or without
        %       '&' prefix
        %   Hardcoded string: 
        %       Parameter starts with a '$' sign. For instance, parameter
        %       value '$Pikachu' is translated into a parameter value of
        %       'Pikachu', wheras parameter value '$$Pikachu' will be
        %       translated into '$Pikachu' when it is sent to the ctor
        %   Optional ctor parameter (key-value pairs):
        %       Parameter name starts with '@'
        %   Get parameter value from dependency injection:
        %       Parameter name starts with '%'
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'&ErrorHandler', 'Exporter', '&mxml.XmlSerializer'};
            defaultValues = {'Exporter', dao.DelimiterValuesDataExporter()};
        end
    end
    
    methods
        function this = MXmlDataAccessor(errorHandler, exporter, serializer, queueFactory)
            if nargin < 4; queueFactory = dao.SimpleDataQueueFactory.empty(); end
            this = this@dao.FileSystemDataAccessor(errorHandler, exporter, queueFactory);
            this.Serializer = serializer;
        end

        function item = load(this, fileName)
            item = this.Serializer.load(fullfile(this.batchPath, fileName));
        end
        
        function filter = fileTypeFilter(this)
            filter = '*.xml';
        end
    end
end
