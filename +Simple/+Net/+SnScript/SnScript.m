classdef SnScript < handle
    %SNISCRIPT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess=public,SetAccess=private)
        server;
        request;
        response;
        app;
        session;
    end
    
    properties (Access=private)
        isMasterPage = false;
        masterPageUrl;
        masterPageContent;
        masterPageContnetTags;
        masterPageContentIndex = 0;
        contentBlocks = {};
    end
    
    methods % Property Accessors
        function val = get.session(this)
            if isa(this.app, 'appd.AppSession') && ~isempty(this.app)
                val = this.app.Context;
            else
                val = [];
            end
        end
    end
    
    methods
        function this = SnScript(request, app)
            this.request = request;
            this.response = request.Response;
            this.server = request.Server;
            this.app = app;
        end
        
        function contentHolder(this, name)
            ex = MException('SNS:MasterPage:ContentHolder:Declare', 'Only master pages may declare content holder tags');
            throw(ex);
        end
        
        function write(this, data)
            this.response.write(this.toText(data));
        end
        
        function startContent(this, name)
            ex = MException('SNS:MasterPage:ContentHolder:Start', 'Only master pages may declare content holder tags');
            throw(ex);
        end
        
        function endContent(this)
            ex = MException('SNS:MasterPage:ContentHolder:End', 'Only master pages may declare content holder tags');
            throw(ex);
        end
        
        function include(this, url)
            this.write(this.get(url));
        end
        
        function html = get(this, url)
            import Simple.Net.SnScript.*;
            virtualServer = SnScriptServer(this.server);
            virtualRequest = this.request.getInternalChainedRequest(virtualServer, url);
            
            virtualServer.requestPipeline(virtualRequest);
            
            html = virtualRequest.Response.Content;
        end
        
        function arr2 = transpose(this, arr)
            arr2 = arr';
        end
        
        function text = toText(this, data)
            if ischar(data)
                text = data;
            elseif iscellstr(data)
                text = strjoin(data, '');
            elseif isnumeric(data)
                text = num2str(data);
            elseif islogical(data)
                if data
                    text = 'true';
                else
                    text = 'false';
                end
            else
                error(['Can''t convert value of type ' class(data) ' to text']);
            end
        end
        
        function done(this)
        end
    end
end

