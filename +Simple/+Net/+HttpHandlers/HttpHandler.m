classdef (Abstract) HttpHandler < handle & matlab.mixin.Heterogeneous
    %HTTPHANDLER implement this abstract class to handle http requests
    
    properties
       server; 
    end
    
    methods
        function this = init(this, server)
            this.server = server;
        end
    end
    
    methods (Abstract)
        ismatch = matches(this, request)
        handleRequest(this, request, app)
    end
end

