classdef TextFileHttpHandler < Simple.Net.HttpHandlers.FileTypeHttpHandler
    methods (Access=protected)
        
        function bool = shouldReadAsTextFile(this, request, app)
            bool = true;
        end
        
        function ext = supportedFileTypes(this)
            ext = {'html' 'htm' 'xml' 'css' 'js' 'json' 'txt'};
        end
        
        function bool = shouldReadFile(this, request, app)
            bool = true;
        end
        
        function doHandleRequest(this, request, app, file)
            response = request.Response;
            switch (file.extension)
                case {'html', 'htm'}
                case 'xml'
                    response.ContentType = 'application/xml; charset=UTF-8';
                case 'js'
                    response.ContentType = 'application/javascript; charset=UTF-8';
                case 'json'
                    response.ContentType = 'application/json; charset=UTF-8';
                case 'css'
                    response.ContentType = 'text/css; charset=UTF-8';
                case 'txt'
                    response.ContentType = 'text/plain; charset=UTF-8';
                otherwise
                    Simple.Net.HttpServer.RaiseBadHttpHandlerMapping(request, class(this));
            end
            
            % Cache for one day
            response.Expires = now + days(365);
            response.CacheControl = ['max-age=' num2str(365*24*60*60)];
            response.Pragma = '';
            
            response.write(file.content);
        end
        
    end
end

