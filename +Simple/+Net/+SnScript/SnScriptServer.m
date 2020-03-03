classdef SnScriptServer < Simple.Net.HttpServer
    %SnScriptServer wraps the http server to perform internal server
    %requests
    properties
        server;
    end
    
    methods
        function this = SnScriptServer(server)
            this@Simple.Net.HttpServer(server.config);
            this.server = server;
            this.networker = Simple.Net.SnScript.MockNetworker(this);
        end
        
        function name = Name(this)
            % Simple network information Script - or SneezeScript
            name = 'SniScript Server'; 
        end
        
        function isactive = isActive(this)
            isactive = true;
        end
        
        function delete(this)
            % skip base class delete method
            delete@handle(this);
        end
    end
end

