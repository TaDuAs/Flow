classdef (Sealed) HttpServerConfig
    %HTTPSERVERCONFIG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rootPath;
        displayInfo;
        defaultfile;
        errorPage;
        networkerType;
        port;
        supportSessions;
        sessionTimeout;
        developerMode;
        connectTimeout;
        readStartTimeout;
        readEndTimeout;
        parpoolWorkersNum;
        app appd.App;
    end
    
    methods
        function this = HttpServerConfig(rootPath, varargin)
            % configure input parser
            parser = inputParser();
            parser.CaseSensitive = false;
            parser.FunctionName = 'Simple.Net.HttpServerConfig';
            
            % setup input schema
            folderValidator = @(x)...
                assert(ischar(x) && ~isempty(x) && exist(x, 'dir'), ...
                       'specified path must be a valid folder path on this computer');
            positiveScalarValidator = @(x) assert(isnumeric(x) && length(x) == 1 && x > 0, 'must be a positive numeric scalar value');
            booleanValidator = @(x) assert(islogical(x), 'must be a logical scalar');
            stringValidator = @(x) assert(ischar(x), 'must be a character vector');
            
            addParameter(parser, 'displayInfo', 'basic', ...
                @(x) assert(ischar(x) && ...
                            any(strcmp(x, {'none','basic','extended'})),...
                            'display info option must be one of these: {''none'',''basic'',''extended''}'));
            addParameter(parser, 'defaultfile', 'index.html', stringValidator);
            addParameter(parser, 'errorPage', '', stringValidator);
            addParameter(parser, 'port', 80, positiveScalarValidator);
            addParameter(parser, 'connectTimeout', 1, positiveScalarValidator);
            addParameter(parser, 'readStartTimeout', 3, positiveScalarValidator);
            addParameter(parser, 'readEndTimeout', 0.8, positiveScalarValidator);
            addParameter(parser, 'supportSessions', true, booleanValidator);
            addParameter(parser, 'sessionTimeout', 3600, positiveScalarValidator);
            addParameter(parser, 'developerMode', false, booleanValidator);
            addParameter(parser, 'networkerType', 'matlabTcpipServer',...
                @(x) assert(ischar(x) && ...
                            any(strcmp(x, {'matlabTcpipServer','javaServerSocket'})),...
                            'must be a valid networker id: {''matlabTcpipServer'',''javaServerSocket''}'));
            addParameter(parser, 'parpoolWorkersNum', 2, @(x) assert(isinteger(x) && x >= 0, 'must be a positive integer'));
            addParameter(parser, 'app', appd.App.empty(), @(x) assert(isa(x, 'appd.App'), 'must be a valid appd.App'));
            
            % validate root path
            if nargin < 1
                throw(MException('SNIS:Config', 'Must specify root path'));
            end
            try
                folderValidator(rootPath);
                
                % parse input
                parse(parser, varargin{:});
            catch ex
                throw(MException('SNIS:Config', ex.message));
            end
            this.rootPath = rootPath;
            this.displayInfo = parser.Results.displayInfo;
            this.defaultfile = parser.Results.defaultfile;
            this.connectTimeout = parser.Results.connectTimeout;
            this.readStartTimeout = parser.Results.readStartTimeout;
            this.readEndTimeout = parser.Results.readEndTimeout;
            this.port = parser.Results.port;
            this.supportSessions = parser.Results.supportSessions;
            this.sessionTimeout = parser.Results.sessionTimeout;
            this.errorPage = parser.Results.errorPage;
            this.developerMode = parser.Results.developerMode;
            this.networkerType = parser.Results.networkerType;
            this.parpoolWorkersNum = parser.Results.parpoolWorkersNum;
            if ~isempty(parser.Results.app)
                this.app = parser.Results.app;
            else
                this.app = appd.App();
            end
        end
    end
end

