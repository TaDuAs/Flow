classdef HttpServer < handle
%HTTPSERVER This class implements a simple http server for small scale applications
% This library is an expansion and generalization over the webserver library by D.Kroon, University of Twente (November 2010)
% Written by TADA, Hebrew University of Jerusalem (2018)
    properties (Constant)
        LogTypes = struct(...
            'Trace', log4m.TRACE, ...
            'Debug', log4m.DEBUG, ...
            'Info', log4m.INFO, ...
            'Warning', log4m.WARN, ...
            'Error', log4m.ERROR, ...
            'FatalError', log4m.FATAL);
    end

    events
        BeforeListen;
        RequestAccepted;
        SessionLoaded;
        BeforeHandleRequest;
        RequestHandled;
        ResponseSent;
    end
    
    properties
        networker;
        config Simple.Net.HttpServerConfig;
        httpHandlers;
    end
    
    properties (Access=private)
        isStopping;
        checkStopFlag;
        workerPool;
        mainServerWorkerHandle;
        messagePollingQueue;
        messageSendingQueue;
        
        % Event listeners
        stopServerEventListener;
    end
    
    methods
        function this = HttpServer(config)
            import Simple.Net.*;
            import Simple.Net.Networking.*;
            
            if nargin < 1 || ~isa(config, 'HttpServerConfig')
                throw(MException('SNIS:ConfigurationError', 'Must specify configuration object of type HttpServerConfig'));
            else
                this.config = config;
            end
            
            this.isStopping = false;
            this.checkStopFlag = false;
            
            this.httpHandlers = {...
                @(server) Simple.Net.HttpHandlers.TextFileHttpHandler().init(server),...
                @(server) Simple.Net.HttpHandlers.ImageHttpHandler().init(server),...
                @(server) Simple.Net.HttpHandlers.WebServiceHttpHandler().init(server),...
                @(server) Simple.Net.SnScript.SnsHttpHandler().init(server),...
                @(server) Simple.Net.SnScript.SnmpHttpHandler().init(server),...
                @(server) Simple.Net.HttpHandlers.ServerMgrHttpHandler().init(server)};
            
            % apparently theres an issue with older versions of matlab 
            % where the tcpip server doesn't recieve data that is sent too 
            % soon after establishing a connection with the client.
            % While this can be easiy fixed by adding a small pause before
            % writing the data to the server, you can't do it when your
            % client is a browser...
            if strcmp(this.config.networkerType, 'matlabTcpipServer') &&...
               exist('tcpip', 'file') && license('checkout', 'instr_control_toolbox') &&...
               ~verLessThan('matlab','9.3') 
                this.networker = TcpipWrapper(this);
            else
                this.networker = JavaSocketWrapper(this);
            end
        end
        
        function initParpool(this)
            if ~this.hasSufficientPCT()
                return;
            end
            if this.config.parpoolWorkersNum > 0
                if isempty(gcp())
                    this.workerPool = parpool('local', this.config.parpoolWorkersNum);
                    mpiInit();
                else
                    this.workerPool = gcp();
                end
            end
        end
        
        function delete(this)
            this.stop();
            delete(this.networker);
            this.networker = [];
            delete(this.workerPool);
            this.workerPool = [];
            this.config = Simple.Net.HttpServerConfig.empty();
            delete@handle(this);
        end
        
        function name = Name(this)
            % Simple net information server - or short SNIS
            % almost as fast as a Sneeze
            name = 'Simple Network Information Server'; 
        end
        
        function isactive = isActive(this)
            isactive = this.networker.isActive();
        end
        
        function this = start(this)
            if this.config.app.Status ~= appd.AppStatus.Loaded
                this.config.app.start();
            end
            
            if this.networker.isActive
                return;
            end
            
            % Initialize the http listener
            this.networker.start();
        end
        
        function this = startAsync(this)
            if ~this.hasSufficientPCT()
                disp('Parallel Computing Toolbox™ or some of its components are not available for you, starting synchronously instead');
                this.start().listen();
                return;
            end
            
            this.initParpool();
            
            if this.config.parpoolWorkersNum > 0
                % Get the worker to construct a data queue on which it can receive
                % messages from the client
                workerQueueConstant = parallel.pool.Constant(@parallel.pool.PollableDataQueue);
                
                % Get the worker to send the queue object back to the client
                this.messageSendingQueue = fetchOutputs(parfeval(@(ppc) ppc.Value, 1, workerQueueConstant));
                
                % start the server in worker process
                this.mainServerWorkerHandle = parfeval(...
                    @(config, queueHolder) ...
                        Simple.Net.HttpServer(config)...
                            .setupWorker(queueHolder)...
                            .start()...
                            .listen(), ...
                        0, ...
                        this.config, ...
                        workerQueueConstant);
                    
                this.log(['Async Webserver Available on http://localhost:' num2str(this.config.port) '/'], '', this.LogTypes.Debug);
            else
                ex = MException('SNIS:CantStartAsync', 'Can''t activate server asynchronously with an empty parpool');
                throw(ex);
            end
        end
        
        function this = setupWorker(this, workerQueueConstant)
            this.messagePollingQueue = workerQueueConstant.Value;
        end
        
        function this = stop(this)
            % terminate stop server event er
            if ~isempty(this.stopServerEventListener)
                delete(this.stopServerEventListener);
                this.stopServerEventListener = [];
            end
            
            if ~isempty(this.mainServerWorkerHandle) && strcmp(this.mainServerWorkerHandle.State, 'running')
                send(this.messageSendingQueue, 'stop');
                try
                    this.networker.wakeServer();
                catch ex
                    if strcmp(ex.identifier, 'SNIS:AsyncServer:WakeFailed')
                        cancel(this.mainServerWorkerHandle);
                    end
                    rethrow(ex);
                end
                
                this.log('Async Webserver Termination Initiated', '', this.LogTypes.Debug);
            elseif this.networker.isActive()
                this.networker.stop();
                this.log('Async Webserver Terminated', '', this.LogTypes.Debug);
            end
            this.isStopping = true;
            delete(this.mainServerWorkerHandle);
            this.mainServerWorkerHandle = [];
        end
        
        function this = listen(this)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

            this.log(['Webserver Available on http://localhost:' num2str(this.config.port) '/'], '', this.LogTypes.Debug);
            
            while(true)
                % Raise before listen event
                notify(this, 'BeforeListen');
                
                % If received a stop command, complete the last request so
                % that no one is left hanging, and then terminate server on
                % the next iteration
                if this.isStopping
                    this.log('SNIS Stopped', '', this.LogTypes.Info);
                    break;
                end
                
                try
                    didTerminate = this.networker.listen();
                catch ex
                    this.logError(ex);
                    continue;
                end

                % If the socket was terminated, stop listening
                if didTerminate
                    break;
                end

                if ~isempty(this.messagePollingQueue)
                    % Check for client messages
                    [message, hasMessage] = poll(this.messagePollingQueue);
                    
                    % Process client messages
                    if hasMessage
                        this.processMessages(message);
                    end
                end
                
                try
                    % Get client request information
                    request = this.networker.read();
                catch ex
                    this.logError(ex);
                    err = MException('HTTP:E400:InvalidRequestFormatOrRequestEmpty', ex.message);
                    try
                        this.handleErrorResponse(Simple.Net.HttpRequest(this, 'Get / HTTP/1.1'), this.config.app, err);
                    catch ex1
                        this.logError(ex1);
                        this.networker.terminateClientConnection();
                    end
                    continue;
                end
                
                % Get client request information
                this.requestPipeline(request);
            end
            
            this.stop();
            this.isStopping = false;
            this.checkStopFlag = false;
        end
        
        function requestPipeline(this, request)
            import Simple.*;
            import Simple.Net.*;

            % this happens when the networker times-out
            if(isempty(request))
                % Write client response
                this.handleEmptyResponse();
                return;
            end

            % Raise RequestAccepted event
            notify(this, 'RequestAccepted');
                
            % Load client session state
            try
                [app, request] = this.loadSession(request);
            catch ex
                this.logError(ex);
                try
                    this.handleErrorResponse(request, this.config.app, ex);
                catch ex1
                    this.logError(ex1);
                end
                return;
            end

            % Raise SessionLoaded event
            notify(this, 'SessionLoaded');
               
            % Handle client request
            try
                this.handleRequest(request, app);
            catch ex
                this.logError(ex);
                try
                    this.handleErrorResponse(request, this.config.app, ex);
                catch ex1
                    this.logError(ex1);
                end
                return;
            end

            % Write client response
            this.handleResponse(request);
        end
        
        function logError(this, ex)
            this.getLogger().log('SNIS', getReport(ex, 'extended'), this.LogTypes.Error);
        end
        
        function log(this, basic, extended, logLevel)
            if nargin < 4; logLevel=this.LogTypes.Trace; end
            
            log = this.getLogger();
            switch (this.config.displayInfo)
                case 'basic'
                    log.log('SNIS', basic, logLevel);
                case 'extended'
                    if nargin < 3 || isempty(extended)
                        message = basic;
                    else
                        if ischar(extended)
                            extendedText = '';
                        elseif isnumeric(extended) || islogical(extended)
                            extendedText = num2str(extended);
                        else
                            extendedText = matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(extended);
                        end
                        
                        message = [basic newline newline extendedText];
                    end
                    log.log('SNIS', message, logLevel);
            end
        end
        
        function clearData(this)
            this.doClearFilesRecursive(this.config.rootPath);
            this.config.app.clearAllSessions();
            this.config.app.persistenceContainer.clearCache();
            this.config.app.reset();
        end
    end
    
    methods (Access=private)
        function haslicense = hasSufficientPCT(this)
            haslicense = license('checkout', 'Distrib_Computing_Toolbox');
            haslicense = haslicense && exist('parallel.pool.PollableDataQueue', 'class') && exist('parallel.pool.Constant', 'class');
        end
        
        function doClearFilesRecursive(this, path)
            fileSysInfo = dir(path);
            files = fileSysInfo(~[fileSysInfo.isdir]);
            dirs = fileSysInfo([fileSysInfo.isdir] & ~strcmp({fileSysInfo.name}, '.') & ~strcmp({fileSysInfo.name}, '..'));
            
            for i = 1:length(dirs)
                curr = dirs(i);
                if curr.isdir
                    this.doClearFilesRecursive([curr.folder '\' curr.name]);
                end
            end
            
            for i = 1:length(files)
                curr = files(i);
                if any(regexpi(curr.name, '_(sns)|(snmp)\.m$'))
                    try
                        delete([curr.folder '\' curr.name]);
                    catch
                        % never mind
                    end
                end
            end
        end
        
        function [app, request] = loadSession(this, request)
            import Simple.Net.*;
            
            if this.config.supportSessions
                if request.Cookie.isKey('sid')
                    sid = request.Cookie('sid');
                    
                    try
                        app = this.config.app.getSession(sid);
                    catch ex
                        if strcmp(ex.identifier, 'AppSession:Expired')
                            this.startSessionAndSetSessionIdCookie(request);
                            HttpServer.RaiseSessionExpiredError();
                        else
                            ex.rethrow();
                        end
                    end
                else
                    sid = this.startSessionAndSetSessionIdCookie(request);
                    app = this.config.app.getSession(sid);
                end
            else
                app = this.config.app.current;
            end
        end
        
        function sid = startSessionAndSetSessionIdCookie(this, request)
            import Simple.Net.*;
            sid = this.config.app.startSession();
            sidCookie = HttpCookie('sid', sid);
            sidCookie.expires = now + seconds(this.config.sessionTimeout);
            sidCookie.httpOnly = true;
            request.Response.setCookie(sidCookie);
        end
        
        function handleRequest(this, request, app)
            import Simple.Net.*;
            
            if nargin < 3 || isempty(app); app = this.config.app; end
            
            % Only support get\post requests
            if ~strcmp(request.Method, {'get', 'post'})
                HttpServer.RaiseMethodNotSupportedRequestError(request);
            end

            % If no filename, use default
            if isempty(request.Filename) || strcmp(request.Filename, '/')
                request.Response.redirect(this.config.defaultfile);
                return;
            end

            % Raise BeforeHandleRequest event
            notify(this, 'BeforeHandleRequest');
               
            % find the correct HttpHandler for the current request
            requestHandler = [];
            for hi = 1:length(this.httpHandlers)
                % Determine if the http handler handles the requested
                % resource
                currHandlerBuilder = this.httpHandlers{hi};
                currHandler = currHandlerBuilder(this);
                if currHandler.matches(request, app)
                    % If a request can be handled by more than one
                    % httphandler, the results will be unexpected.
                    % throw exception to let the developers know they did a
                    % bad job identifying requested resource types
                    if ~isempty(requestHandler)
                        HttpServer.RaiseAmbiguousRequestError(request);
                    end
                    requestHandler = currHandler;
                end
            end
            
            % if no appropriate http handler is found, let the developers
            % know they did a bad job... ;)
            if isempty(requestHandler)
                HttpServer.RaiseUnhandledRequestError(request);
            end

            % Delegate the current request to the correct HttpHandler
            requestHandler.handleRequest(request, app);
            
            % Raise RequestHandled event
            notify(this, 'RequestHandled');
        end
        
        function handleResponse(this, request)
            response = request.Response;
            this.log('Response sent to client', response, this.LogTypes.Debug); 

            try
                response.send();
            catch ex
                this.networker.terminateClientConnection();
                this.logError(ex);
            end
            
            % Raise ResponseSent event
            notify(this, 'ResponseSent');
        end
        
        function handleEmptyResponse(this)
            this.networker.terminateClientConnection();
        end
        
        function handleErrorResponse(this, request, app, ex)
            Simple.Net.HttpHandlers.ErrorHttpHandler().init(this, ex).handleRequest(request, app);
            this.handleResponse(request);
        end
        
        function processMessages(this, message)
            switch message
                case 'stop'
                    this.stopServerEventListener = addlistener(this, 'BeforeListen', @(server, args) server.stop());
            end
        end
        
        function logger = getLogger(this)
            fullpath = [this.config.rootPath '\log\info_' datestr(now, 'yyyy-mm-dd') '.log'];
            folder = fileparts(fullpath);
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            logger = log4m.getLogger(fullpath);
            
            if ~strcmp(logger.fullpath, fullpath)
                logger = log4m.forceNewLogger(fullpath);
            end
        end
    end
    
    methods (Static)
       
        function RaiseFileNotFoundError(request, msg)
            if nargin < 2; msg = ['The requested file ' request.Url ' was not found']; end
            ex = MException('HTTP:E404:NotFound', msg);
            throw(ex);
        end
        
        function RaiseAmbiguousRequestError(request, msg)
            if nargin < 2; msg = ['The request ' request.Url ' can be delegated to more than one HttpHandler']; end
            ex = MException('HTTP:E500:AmbiguousRequest', msg);
            throw(ex);
        end
        
        function RaiseBadHttpHandlerMapping(request, handlerType, msg)
            if nargin < 2; msg = ['The request ' request.Url ' was passed to the wrong HttpHandler ' handlerType]; end
            ex = MException('HTTP:E500:BadHandlerMapping', msg);
            throw(ex);
        end
        
        function RaiseUnhandledRequestError(request, msg)
            if nargin < 2; msg = ['The request ' request.Url ' is not supported']; end
            ex = MException('HTTP:E501:Unhandled', msg);
            throw(ex);
        end
        
        function RaiseMethodNotSupportedRequestError(request, msg)
            if nargin < 2; msg = 'Method Not Allowed'; end
            ex = MException('HTTP:E405:MethodNotSupported', msg);
            throw(ex);
        end
        
        function RaiseSessionExpiredError(request, msg)
            if nargin < 2; msg = 'Session expired'; end
            ex = MException('HTTP:E440:SessionExpired', msg);
            throw(ex);
        end
        
        function RaiseTerminatedResponseError(request, msg)
            if nargin < 2; msg = 'Trying to write to terminated response'; end
            ex = MException('HTTP:E500:TerminatedResponse', msg);
            throw(ex);
        end
    end
end

