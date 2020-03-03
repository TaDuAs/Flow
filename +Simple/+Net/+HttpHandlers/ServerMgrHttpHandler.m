classdef ServerMgrHttpHandler < Simple.Net.HttpHandlers.HttpHandler
    %SERVERMGRHTTPHANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function ismatch = matches(this, request, app)
            ismatch = any(regexpi(request.Filename, '\/.*\.server$'));
        end
        function handleRequest(this, request, app)
            tok = regexpi(request.Filename, '\/(?<cmd>.*)\.server$', 'names');
            command = tok.cmd;
            
            response = request.Response;
            response.ContentType = 'text/plain';
            
            switch (command)
                case 'wake'
                    response.write('yawn');
                otherwise
                    response.write('Unknown command');
            end
        end
    end
end

