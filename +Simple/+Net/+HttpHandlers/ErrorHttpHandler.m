classdef ErrorHttpHandler < Simple.Net.HttpHandlers.FileTypeHttpHandler
    properties
        errorToHandle;
    end
    
    methods
        function this = init(this, server, ex)
            init@Simple.Net.HttpHandlers.FileTypeHttpHandler(this, server);
            if nargin > 1
                this.errorToHandle = ex;
            end
        end
        
        function ismatch = matches(this, request, app)
            ismatch = false;
        end
    end
    methods (Access=protected)
        function bool = shouldReadAsTextFile(this, request, app)
            bool = true;
        end
        
        function ext = supportedFileTypes(this)
            ext = {};
        end
        function bool = shouldReadFile(this, request, app)
            try
                % If this is a webservice, don't read the error page, as
                % we're gonna return the response as an XML message
                serviceHandler = Simple.Net.HttpHandlers.WebServiceHttpHandler().init(this.server);
                bool = ~serviceHandler.matches(request, app);
            catch 
                bool = false;
            end
        end
        
        function doHandleRequest(this, request, app, file)
            if ~isempty(this.errorToHandle); ex = this.errorToHandle; else; ex = lasterror; end
            
            response = request.Response;
            
            % prepare error details
            status = 500;
            err.message = ex.message;
            err.reason = ex.message;
            err.identifier = ex.identifier;
            if startsWith(ex.identifier, 'HTTP:', 'IgnoreCase', true)
                tokens = regexp(ex.identifier, '^HTTP:E(?<stat>\d{3})(?<reason>:\w+)?', 'names');
                status = str2double(tokens.stat);
                if isfield(tokens, 'reason') && ~isempty(tokens.reason)
                    err.reason = tokens.reason(2:end);
                end
            end
            if this.server.config.developerMode && isa(ex, 'MException')
                err.report = getReport(ex);
            end
            
            % Set error details to response
            response.Status = status;
            
            % Handle error page
            if isfield(file, 'content') && ~isempty(file.content)                 
                body = strrep(file.content, '{ErrorCode}', num2str(status));
                body = strrep(body, '{ErrorText}', err.message);
                body = strrep(body, '{ErrorId}', err.identifier);
                body = strrep(body, '{ErrorReport}', err.report);
                response.write(body);
            % Handle error for web service response
            else
                response.ContentType='application/xml; charset=UTF-8';
                responseSimple.Net.Envelope = Simple.Net.Envelope.Error(status, err, []);
                body = Simple.IO.MXML.toxml(responseSimple.Net.Envelope);
                response.write(body);
            end
        end
        
        function filePath = getFullFilePath(this, request, app)
            if ~isempty(this.server.config.errorPage)
                filePath = this.server.config.errorPage;
            else
                % handle default file
                filePath = which('Simple.Net.HttpServer');
                filePath = [filePath(1:end-length('HttpServer.m')) 'Templates\error.html'];
            end
        end
        
    end
end