classdef (Abstract) Networker < handle
    properties
        server;
    end
    
    methods
        function this = Networker(server)
            this.server = server;
        end
        
        function request = read(this)
            requestdata = this.doReadRequest();
            
            if(isempty(requestdata))
                request = [];
                return;
            end

            this.server.log('request accepted', char(requestdata(1:min(1000,end))), this.server.LogTypes.Debug); 

            % Parse request data
            request = Simple.Net.HttpRequest(this.server, requestdata);
            
            this.server.log(...
                ['request succesfully read: ' request.Method ' ' request.Url ' ' request.Protocol],...
                request,...
                this.server.LogTypes.Debug); 
        end
    end
    
    methods (Abstract)
        % Determines whether this networker is active
        isactive = isActive(this)
        
        % Setup networker
        start(this)
        
        % Terminate networking
        stop(this)
        
        % Listen for client requests
        didTerminate = listen(this)
        
        % Send response to client
        sendResponse(this, header, content)
        
        % Terminate connection to current client
        terminateClientConnection(this)
        
        % Used to wake server up if it has no timeout when listening to
        % client requests
        wakeServer(this)
    end
    
    methods (Abstract, Access=protected)
        % Read the data of accepted request
        requestData = doReadRequest(this)
    end
end

