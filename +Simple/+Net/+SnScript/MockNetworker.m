classdef MockNetworker < Simple.Net.Networking.Networker
    properties
        request;
    end
    
    methods
        function this = MockNetworker(server, request)
            this@Simple.Net.Networking.Networker(server);
        end
        
        % Determines whether this networker is active
        function isactive = isActive(this)
            isactive = true;
        end
        
        % Setup networker
        function start(this)
        end
        
        % Terminate networking
        function stop(this)
        end
        
        % Listen for client requests
        function didTerminate = listen(this)
            didTerminate = false;
        end
        
        % Send response to client
        function sendResponse(this, header, content)
        end
        
        % Terminate connection to current client
        function terminateClientConnection(this)
        end
        
        function wakeServer(this)
        end
    end
    
    methods (Access=protected)
        % Read the data of accepted request
        function requestData = doReadRequest(this)
            requestData = [];
        end
    end
end

