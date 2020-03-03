classdef TcpipWrapper < Simple.Net.Networking.Networker
    %TCPWRAPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tcpListener;
    end
    
    methods
        function this = TcpipWrapper(server)
            this@Simple.Net.Networking.Networker(server);
        end
    
        function delete(this)
            this.stop();
        end
        
        % Determines whether this networker is active
        function isactive = isActive(this) 
            isactive = ~isempty(this.tcpListener) &&...
                strcmp(this.tcpListener.Status, 'open');
        end
        
        % Setup networker
        function start(this)
            if this.isActive
                return;
            end
            
            this.tcpListener = tcpip('0.0.0.0', this.server.config.port,...
                'NetworkRole', 'server',...
                'Timeout', this.server.config.readStartTimeout);
            
            this.tcpListener.OutputBufferSize = 20*1024;
        end
        
        function terminateClientConnection(this)
            if ~this.isActive
                return;
            end
            
            try
                fclose(this.tcpListener);
            catch
                % if theres a problem it must be due to bad setup, socket
                % closed already or something like that.
                % simply ignore that and go on with our lives...
            end
        end
        
        % Terminate networking
        function stop(this)
            try
                fclose(this.tcpListener);
            catch
                % if theres a problem it must be due to bad setup, socket
                % closed already or something like that.
                % simply ignore that and go on with our lives...
            end
            delete(this.tcpListener);
            this.tcpListener = [];
        end
        
        % Listen for client requests
        function didTerminate = listen(this)
            try
                fopen(this.tcpListener);
            catch ex
                try
                    fclose(this.tcpListener);
                catch
                    % hope for the best
                end
                ex.rethrow();
            end
            didTerminate = false;
        end
        
        % Send response to client
        function sendResponse(this, header, content)
            try
                this.write(int8(header));
                this.write(int8(content));
                fclose(this.tcpListener);
            catch ex
                try
                    fclose(this.tcpListener);
                catch 
                    % hope for the best
                end
                ex.rethrow();
            end
        end
        
        
        function wakeServer(this)
%             url = matlab.net.URI(['http://localhost:' num2str(this.server.config.port) '/wake.server']);
%             req = matlab.net.http.RequestMessage;
            
%             wakeupCall = tcpclient('localhost', this.server.config.port, 'ConnectTimeout', 2);
            wakeupCall = tcpip('localhost', 4000, 'NetworkRole', 'client');
            httpRequestText = 'POST /wake.server HTTP/1.1';
            
            failedToConnect = 0;
            
            for i = 1:3
                try
                    % open connection
                    fopen(wakeupCall);
                    
                    % send wake up call request
                    fwrite(wakeupCall, int8(httpRequestText(:)));
                    
                    % read response
                    response = char(fread(wakeupCall, 12)');
                    
                    % close connection
                    fclose(wakeupCall);
                    
                    % check if the request was handled
                    if length(response) >= 3 && strcmp(response(end-2:end), '200')
                        delete(wakeupCall);
                        return;
                    end
                catch err
                    if strcmp(err.identifier, 'instrument:fopen:opfailed')
                        failedToConnect = failedToConnect + 1;
                        if failedToConnect < i
                            % server was terminated even though no response
                            % was received, termination was successfull
                            return;
                        end
                    end
                    try
                        fclose(wakeupCall);
                    catch err2
                        % hope for the best
                    end
                end
            end
            
            delete(wakeupCall);
            
            ex = MException('SNIS:AsyncServer:WakeFailed', 'Can''t wake async server, it is either extremely busy, inactive or not responding');
            throw(ex);
        end
    end
    
    methods (Access=protected)
        function write(this, data)
            if ~this.isActive()
                return;
            end
            
            % Get connection buffer size
            bufferSize = this.tcpListener.OutputBufferSize;
            
            % Write all data
            for i = 1:ceil(length(data)/bufferSize)
                startIndex = (i-1)*bufferSize + 1;
                bufferData = data(startIndex:min(startIndex+bufferSize-1, end));
                fwrite(this.tcpListener, bufferData(:), 'int8');
            end
        end
        
        % Read the data of accepted request
        function requestData = doReadRequest(this)
            data=zeros(1,1000000,'int8'); tBytes=0;
            tstart=tic;
            while(true)
                nBytes = this.tcpListener.BytesAvailable;
                partdata = [];
                if ~isempty(nBytes) && nBytes > 0
                    try
                        partdata = fread(this.tcpListener, nBytes);
                    catch ex
                        fclose(this.tcpListener);
                        ex.rethrow();
                    end
                    data(tBytes+1:tBytes+nBytes) = partdata;
                    tBytes=tBytes+nBytes;
                end
                % Only exist if the buffer is empty and some request-data
                % is received, or if the time is larger then 1.5 seconds
                t=toc(tstart);
                if(isempty(partdata)&&(t>this.server.config.readEndTimeout)&&(tBytes>0)), break; end
                if(isempty(partdata)&&(t>this.server.config.readStartTimeout)), break; end
            end
            requestData=data(1:tBytes);
        end
    end

end

