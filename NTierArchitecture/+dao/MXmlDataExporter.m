classdef MXmlDataExporter < dao.FSOutputDataExporter & mfc.IDescriptor
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
            ctorParams = {'%mxml.XmlSerializer'};
            defaultValues = {};
        end
    end
    
    methods
        function this = MXmlDataExporter(serializer)
            this.Serializer = serializer;
        end
        
        function save(this, data, output, path)
            if nargin >= 3 && ~isempty(output)
                exportData = struct();
                exportData.data = data;
                exportData.output = output;
            end
            
            this.Serializer.save(exportData, path);
        end
        
        function [data, output] = load(this, path)
            data = this.Serializer.load(path);
            
            if isstruct(data) && isfield(data, 'data')
                data = data.data;
                
                if isfield(data, 'output')
                    output = data.output;
                elseif isfield(data, 'meta')
                    output = data.meta;
                end
            end
        end
        
        function postfix = outputFilePostfix(this)
            postfix = 'xml';
        end
    end
    
end

