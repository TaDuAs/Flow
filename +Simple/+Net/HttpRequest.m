classdef HttpRequest < handle
    properties (GetAccess=public,SetAccess=private)
        Server;
        Cookie;
        Url;
        Method;
        Protocol;
        Filename;
        Query;
        Host;
        UserAgent;
        Accept;
        AcceptLanguage;
        AcceptEncoding;
        AcceptCharset;
        KeepAlive;
        Connection;
        ContentLength;
        ContentType;
        Content;
        Response;
    end
    
    methods
        function this = HttpRequest(server, requestdata)
            
            this.Server = server;
            this.Cookie = containers.Map();
            this.Content=struct;
            
            request_text=char(requestdata);
            request_lines = regexp(request_text, '\r\n+', 'split');
            request_words = regexp(request_lines, '\s+', 'split');
            
            this.parseHeader(request_lines, request_words);
            
            this.parseContent(requestdata, request_text);
            
            this.Response = Simple.Net.HttpResponse(this.Server, this);
        end   
        
        % generate new internal request
        % copy headers from this request
        function request = getInternalChainedRequest(this, server, url, method, passQuery, passContent)
            if nargin < 5 || isempty(passQuery); passQuery = false; end
            if nargin < 6 || isempty(passContent); passContent = false; end
            if nargin < 4 || isempty(method); method = 'GET';
            elseif nargin >= 6 && passContent; method = 'POST'; end
            
            request = Simple.Net.HttpRequest(server, [method ' ' url ' ' this.Protocol]);
            properties = fields(this);
            for propI = 1:length(properties)
                propName = properties{propI};
                
                switch (propName)
                    case 'Query'
                        % Check if should copy query
                        if ~passQuery
                            continue;
                        end
                    case 'Content'
                        % Check if should copy post content
                        if ~passContent 
                            continue;
                        end
                    case {'Server', 'Response', 'Filename', 'Protocol', 'Method', 'Url', 'Host'}
                        % Ignore all these, they are fine as set by the new
                        % request initialization
                        continue;
                    case 'Cookie'
                        % copy all the cookies
                        cookieNames = this.Cookie.keys;
                        for cookI = 1:length(cookieNames)
                            request.Cookie(cookieNames{cookI}) = this.Cookie(cookieNames{cookI});
                        end
                        continue;
                end
                request.(propName) = this.(propName);
            end
        end
        
        % Get value from request, first from post content, if its missing 
        % try to get it from the query string, if it's missing in both
        % return empty string
        function value = get(this, name)
            if isfield(this.Content, name)
                value = this.Content.(name);
            elseif isfield(this.Query, name)
                value = this.Query.(name);
            else
                value = '';
            end
        end
        
    end
    
    methods (Access=private)
        function parseContent(this, requestdata, request_text)
            import Simple.Net.*;
            if ~isempty(this.ContentLength) && this.ContentLength > 0
                cl= this.ContentLength;
                str=request_text(end-cl+1:end);
                data=requestdata(end-cl+1:end);
                if ~isempty(this.ContentType)
                    this.ContentType.Type=''; this.ContentType.Boundary='&';
                end
                switch (this.ContentType.Type)
                    case {'application/x-www-form-urlencoded',''}
                        str=rmvp(str);
                        words = regexp(str, '&', 'split');
                        for i=1:length(words)
                            words2 = regexp(words{i}, '=', 'split');
                            this.Content.(words2{1})=words2{2};
                        end
                    case 'multipart/form-data'
                        pos=strfind(str,this.ContentType.Boundary);
                        while((pos(1)>1)&&(str(pos(1)-1)=='-'))
                            this.ContentType.Boundary=['-' this.ContentType.Boundary];
                            pos=strfind(str,this.ContentType.Boundary);
                        end

                        for i=1:(length(pos)-1)
                            pstart=pos(i)+length(this.ContentType.Boundary);
                            pend=pos(i+1)-3; % Remove "13 10" End-line characters
                            subrequestdata=data(pstart:pend);
                            subdata= multipart2struct(subrequestdata,this.server.config);
                            this.Content.(subdata.Name).Filename=subdata.Filename;
                            this.Content.(subdata.Name).ContentType=subdata.ContentType;
                            this.Content.(subdata.Name).ContentData=subdata.ContentData;
                        end
                    otherwise
                        disp('unknown')
                end
            end
        end
        
        function parseHeader(this, request_lines, request_words)
            import Simple.Net.*;
            
            for i=1:length(request_lines)
                line=request_lines{i};
                if(isempty(line)), break; end
                type=request_words{i}{1};
                switch(lower(type))
                    case {'get','post'}
                        this.Url = this.decodeUrl(request_words{i}{2});
                        this.Method = lower(type);
                        this.Protocol = request_words{i}{3};
                        urlPattern = '(?:https?:\/\/)?(?:[\w\.]+(?:\:\d+)?)?(?<path>[\w\/\. -%]+(?:\.\w+)?)(?<query>\?(?:(?:\w+(?:=?[\w \\\/@\$%#\!\?~`''";\*\(\)\+=:\.-]+)?)\&?)*)?';
                        tokens= regexp(this.Url, urlPattern, 'names');
                        this.Filename = tokens.path;

                        % parse query string
                        this.Query = struct;
                        if ~isempty(tokens) && isfield(tokens, 'query') && ~isempty(tokens.query)
                            params = strsplit(tokens.query(2:end), '&');
                            for qspi = 1:length(params)
                                currParam = params{qspi};
                                eqi = find(currParam=='=');
                                if ~isempty(eqi) && eqi > 1
                                    this.Query.(currParam(1:eqi-1)) = currParam(eqi+1:end);
                                end
                            end
                        end
                    case 'host:'
                        this.Host=rmvp(line(7:end));
                    case 'user-agent:'
                        this.UserAgent=rmvp(line(13:end));
                    case 'accept:'
                        this.Accept=rmvp(line(9:end));
                    case 'accept-language:'
                        this.AcceptLanguage=rmvp(line(18:end));
                    case 'accept-encoding:'
                        this.AcceptEncoding=rmvp(line(18:end));
                    case 'accept-charset:'
                        this.AcceptCharset=rmvp(line(17:end));
                    case 'keep-alive:'
                        this.KeepAlive=rmvp(line(13:end));
                    case 'connection:'
                        this.Connection=rmvp(line(13:end));
                    case 'content-length:'
                        this.ContentLength=str2double(rmvp(line(17:end)));
                        if isnan(this.ContentLength) || isinf(this.ContentLength)
                            this.ContentLength = [];
                        end
                    case 'content-type:'
                        %lines=rmvp(line(15:end));
                        switch rmvp(request_words{i}{2})
                            case {'application/x-www-form-urlencoded','application/x-www-form-urlencoded;'}
                                this.ContentType.Type='application/x-www-form-urlencoded';
                                this.ContentType.Boundary='&';
                            case {'multipart/form-data','multipart/form-data;'}
                                this.ContentType.Type='multipart/form-data';
                                str=request_words{i}{3};
                                this.ContentType.Boundary=str(10:end);
                            otherwise
                                disp('unknown')
                        end
                    case {'set-cookie:', 'cookie:'}
                        cookies = strsplit(rmvp(line(find(line==':', 1, 'first')+1:end)), '; ');
                        for ci = 1:length(cookies)
                            currCookie = strsplit(cookies{ci}, '=');
                            this.Cookie(strtrim(currCookie{1})) = strtrim(currCookie{2});
                        end

                    otherwise
                end
            end
        end
        
        function decoded = decodeUrl(this, url)
            decoded = strrep(url, '%20', ' ');
        end
    end
end

