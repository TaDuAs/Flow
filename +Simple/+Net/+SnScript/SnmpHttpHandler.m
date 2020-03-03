classdef SnmpHttpHandler < Simple.Net.SnScript.SnsHttpHandler
    %SNMPHTTPHANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Access=protected)
        function ext = supportedFileTypes(this)
            ext = {'snmp'};
        end
        
        function doHandleRequest(this, request, app, file)
            response = request.Response;
            response.ContentType='text/plain';
            
            % Prepare the script file
            functionName = this.doPrepareSnScript(request, app, file);
            
            % evaluate the script - get function handle and save it for
            % later.
            response.write(functionName);
        end
        
        function out = handleUniqueScriptBlock(this, scriptBlock)
            % Content holder decleration tag
            if any(regexp(scriptBlock, '<%\?\s*ContentHolder\s+\w+\s*%>'))
                % this regex extracts the content holders name
                tokens = regexp(scriptBlock, '^<%\?\s*ContentHolder\s+(?<tag>\w+)\s*%>$', 'names');
                if ~isempty(tokens) && isfield(tokens, 'tag') && ~isempty(tokens.tag)
                    out = ['sns.contentHolder(''' tokens.tag ''');'];
                else
                    ex = MException('SNS:MasterPage:ContentHolder:TagMissing', 'Must specify content holder tag');
                    throw(ex);
                end
            else
                out = handleUniqueScriptBlock@Simple.Net.SnScript.SnScript(this, scriptBlock);
            end
        end
        
    end
    
end

