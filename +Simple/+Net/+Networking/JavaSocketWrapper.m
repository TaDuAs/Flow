classdef JavaSocketWrapper < Simple.Net.Networking.Networker
    %JAVASOCKETWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tcpListener;
    end
    
    methods
        function this = JavaSocketWrapper(server)
            this@Simple.Net.Networking.Networker(server);
        end
        
        function delete(this)
            this.stop();
        end
        
        function isactive = isActive(this)
            isactive = ~isempty(this.tcpListener) && ...
                isfield(this.tcpListener, 'socket') &&...
                ~isempty(this.tcpListener.socket) && ...
                this.tcpListener.socket ~= -1;
        end
        
        function start(this)
            if this.isActive
                return;
            end
            
            % Initialize the http listener
            this.tcpListener = Simple.Net.Networking.JavaTcpServer('initialize', [], this.server.config.port, this.server.config);
        end
        
        function terminateClientConnection(this)
            try
                if this.isActive()
                    % Fluh the output stream
                    this.tcpListener = Simple.Net.Networking.JavaTcpServer('write', int8([]), this.server.config.port, this.server.config);
                end
            catch 
                % if theres a problem it must be due to bad setup, socket
                % closed already or something like that.
                % simply ignore that and go on with our lives...
            end
        end
        
        function stop(this)
            try
                if this.isActive()
                    Simple.Net.Networking.JavaTcpServer('close', [], this.server.config.port, this.server.config);
                end
                delete(this.tcpListener);
            catch 
                % if theres a problem it must be due to bad setup, socket
                % closed already or something like that.
                % simply ignore that and go on with our lives...
            end
            this.tcpListener = [];
        end
        
        % Listen for client requests
        function didTerminate = listen(this)
            didTerminate = false;
            
            % Wait for connections of browsers
            this.tcpListener = Simple.Net.Networking.JavaTcpServer('accept', this.tcpListener, [], this.server.config);

            % If socket is -1, the user has close the "Close Window"
            if(this.tcpListener.socket==-1)
                this.tcpListener = [];
                didTerminate = true;
            end
        end
        
        % Send response to client
        function sendResponse(this, header, content)
            % write the Http response back to the clients stream
            if isrow(content)
                data = int8(content);
            else
                data = int8(content)';
            end
            
            Simple.Net.Networking.JavaTcpServer('write', this.tcpListener, int8(header), this.server.config);
            Simple.Net.Networking.JavaTcpServer('write', this.tcpListener, data, this.server.config);
        end
        
        function wakeServer(this)
            % The server has a network timeout and will therefore wake up
            % automatically soon enough
        end
    end
    
    methods (Access=protected)
        % Read the data of accepted request
        function requestdata = doReadRequest(this)
            [this.tcpListener, requestdata] = Simple.Net.Networking.JavaTcpServer('read', this.tcpListener, [], this.server.config);
        end
    end
end

