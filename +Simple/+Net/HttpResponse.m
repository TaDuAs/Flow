classdef HttpResponse < handle
    properties
        Status;
        Expires;
        CacheControl;
        Pragma;
        Connection;
        ContentType;
        LastModified;
        AcceptRanges;
        ETag;
        KeepAlive;
        Location;
    end
    
    properties (Access=private)
        RemovedCookies;
        SetCookies;
        XPoweredBY;
        Date;
        IsTerminated;
    end
    
    properties (GetAccess=public,SetAccess=private)
        Server;
        Request;
        Content;
    end
    
    methods
        function sr = StatusReason(this)
            import Simple.Net.HttpResponse;
            sr = HttpResponse.StatusCodes{[HttpResponse.StatusCodes{:,1}]==this.Status, 2};
        end
        
        function Status.set(this, value)
            if ~any([Simple.Net.HttpResponse.StatusCodes{:,1}]==value)
                MException('HTTP:E500:InvalidResponseStatus', ['Specified response status code ' num2str(value) ' is not a valid HTTP status or is not yet implemented']).throw();
            end
            this.Status = value;
        end
    end
    
    methods
        function this = HttpResponse(server, request)
            this.Request = request;
            this.Server = server;
            this.RemovedCookies = {};
            this.SetCookies = containers.Map();
            this.Date = now;
            this.Pragma = 'no-cache';
            this.CacheControl = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0';
            this.Connection = 'close';
            this.ContentType = 'text/html; charset=UTF-8';
            this.Expires = now - hours(1);
            
            this.Status = 200;
            this.XPoweredBY = ['Matlab' version]; 
            this.IsTerminated = false;
        end
        
        function removeCookie(this, name)
            this.SetCookies.remove(name);
            if ~any(strcmp(this.RemovedCookies, cookie.name))
                this.RemovedCookies{length(this.RemovedCookies) + 1} = name;
            end
        end
        
        function setCookie(this, cookie)
            this.RemovedCookies = this.RemovedCookies(~strcmp(this.RemovedCookies, cookie.name));
            this.SetCookies(cookie.name) = cookie;
        end
        
        function write(this, data)
            if this.IsTerminated
                Simple.Net.HttpServer.RaiseTerminatedResponseError(this.Request);
            end
            
            if isrow(data)
                this.Content = [this.Content, data];
            else
                this.Content = [this.Content, data'];
            end
        end
        
        function send(this)
            this.terminate();
            this.Server.networker.sendResponse(this.getHeaderText(), this.Content);
        end
        
        function redirect(this, url)
            this.Status = 307;
            this.Location = url;
            this.terminate();
        end
        
        % flag as closed response, no more content is to be written
        function terminate(this)
            this.IsTerminated = true;
        end
    end
    
    methods (Access=private)
        function text = getRedirectHeaderText(this)
            text= [...
                this.Request.Protocol ' ' num2str(this.Status) ' ' this.StatusReason newline...
                ];
        end
        function text=getHeaderText(this)
            
            text= [...
                this.Request.Protocol ' ' num2str(this.Status) ' ' this.StatusReason newline...
                'Date: ' Simple.getDateTimeString(this.Date, 'full Z', 'GMT') newline...
                'Server: ' this.Server.Name newline...
                'X-Powered-By: ' this.XPoweredBY newline...
                'Expires: ' Simple.getDateTimeString(this.Expires, 'full Z', 'GMT') newline... 'local') newline...
                'Cache-Control: ' this.CacheControl newline...
                'Connection: ' this.Connection newline...
                'Content-Type: ' this.ContentType newline...
                'Content-Length: ' num2str(length(this.Content)) newline...
                ];
            
            if this.Status < 400 && this.Status >= 300
                text = [text 'Location: ' this.Location newline];
            end
            
            if ~isempty(this.Pragma)
                text = [text 'Pragma: ' this.Pragma newline];
            end
            
            if ~isempty(this.LastModified)
                text = [text 'Last-Modified: ' Simple.getDateTimeString(this.LastModified, 'full Z', 'GMT') newline];% 'local') newline];
            end
            
            if ~isempty(this.AcceptRanges)
                text = [text 'Accept-Ranges: ' this.AcceptRanges newline];
            end
            
            if ~isempty(this.KeepAlive)
                text = [text 'Keep-Alive: ' this.KeepAlive newline];
            end
            
            if ~isempty(this.ETag)
                text = [text 'ETag: ' this.ETag newline];
            end
            
            setCookeyKeys = this.SetCookies.keys;
            for ci = 1:length(setCookeyKeys)
                cookie = this.SetCookies(setCookeyKeys{ci});
                text = [text 'Set-Cookie: ' cookie.toString() newline];
            end
            
            removeCookeysKeys = this.RemovedCookies;
            for ci = 1:length(removeCookeysKeys)
                cookey = removeCookeysKeys{ci};
                text = [text 'Set-Cookie: ' cookey '=removed_cookey; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT;' newline];
            end
            
            text = sprintf([text newline]);
        end
    end
    
    properties (Constant)
        StatusCodes = {...
            200, 'OK';...
            303, 'See Other';...
            307, 'Temporary Redirect';...
            308, 'Permanent Redirect';...
            400, 'Bad Request';...
            401, 'Unauthorized';...
            402, 'Payment Required';...
            403, 'Forbidden';...
            404, 'Not Found';...
            405, 'Method Not Allowed';...
            408, 'Request Timeout';...
            418, 'I''m a teapot';...
            440, 'Login Time-out';...
            500, 'Internal Server Error';...
            501, 'Not Implemented';...
            503, 'Service Unavailable';};
    end
end

