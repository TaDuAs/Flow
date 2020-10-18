classdef Log4Wrapper < logs.ILogger & mfc.IDescriptor
    % Wrapper class for the excelent log4m logger.
    % This wrapper implements the logs.ILogger interface.
    % While logs.ILogger basically exposes the log4m api, it allows further
    % abstraction and easier dependency injection without static methods
    % than the original log4m.
    %
    % Author: TADA 2020
    
    properties
        LogPath char;
    end
    
    properties (Dependent)
        CommandWindowLevel logs.LogType;
        LogLevel logs.LogType;
    end
    
    methods % property accessors
        function set.CommandWindowLevel(this, loglevel)
            logger = this.getLogger();
            logger.setCommandWindowLevel(this.convertLogType2Log4m(loglevel));
        end
        function loglevel = get.CommandWindowLevel(this)
            logger = this.getLogger();
            loglevel = this.convertLog4mType2LogType(logger.commandWindowLevel);
        end
        
        function set.LogLevel(this, loglevel)
            logger = this.getLogger();
            logger.setCommandWindowLevel(this.convertLogType2Log4m(loglevel));
        end
        function loglevel = get.LogLevel(this)
            logger = this.getLogger();
            loglevel = this.convertLog4mType2LogType(logger.logLevel);
        end
    end
    
    methods (Hidden)
        % provides initialization description for mfc.MFactory
        % ctorParams is a cell array which contains the parameters passed to
        % the ctor and which properties are to be set during construction
        % 
        % ctor dependency rules:
        %   Extract from fields:
        %       Parameter name is the name of the property, with or without
        %       '&' prefix
        %   Hardcoded string: 
        %       Parameter starts with a '$' sign. For instance, parameter
        %       value '$Pikachu' is translated into a parameter value of
        %       'Pikachu', wheras parameter value '$$Pikachu' will be
        %       translated into '$Pikachu' when it is sent to the ctor
        %   Optional ctor parameter (key-value pairs):
        %       Parameter name starts with '@'
        %   Get parameter value from dependency injection:
        %       Parameter name starts with '%'
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'LogPath'};
            defaultValues = {'LogPath', ''};
        end
    end
    
    methods
        function this = Log4Wrapper(logPath)
            if nargin < 1
                logPath = 'log4m.log';
            end
            
            this.LogPath = logPath;
        end
        
        function setFilename(this, logPath)
            this.LogPath = logPath;
        end
        
        function logPath = getFilename(this)
            logPath = this.LogPath;
        end
        
        function setCommandWindowLevel(this, loglevel)
            this.CommandWindowLevel =  loglevel;
        end
        
        function setLogLevel(this, loglevel)
            this.LogLevel = loglevel;
        end
        
        % Log a message with specified level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        function log(this, funcName, message, loglevel)
            loglevel = logs.validateLogType(loglevel);
            if numel(loglevel) ~= 1
                throw(MException('logs:Log4Wrapper:log:AmbigousLogLevel', 'loglevel must be a scalar'));
            end
            
            logger = this.getLogger();
            logger.log(funcName, message, this.convertLogType2Log4m(loglevel));
        end
        
        % TRACE Log a message with the TRACE level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        function trace(this, funcName, message)
            logger = this.getLogger();
            logger.trace(funcName, message);
        end
        
        % TRACE Log a message with the DEBUG level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        function debug(this, funcName, message)
            logger = this.getLogger();
            logger.debug(funcName, message);
        end
 
        % TRACE Log a message with the INFO level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        function info(this, funcName, message)
            logger = this.getLogger();
            logger.info(funcName, message);
        end
            
        % TRACE Log a message with the WARN level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        function warn(this, funcName, message)
            logger = this.getLogger();
            logger.warn(funcName, message);
        end
                
        % TRACE Log a message with the ERROR level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        function error(this, funcName, message)
            logger = this.getLogger();
            logger.error(funcName, message);
        end
                
        % TRACE Log a message with the FATAL level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        function fatal(this, funcName, message)
            logger = this.getLogger();
            logger.fatal(funcName, message);
        end
    end
    
    methods (Access=private)
        function logger = getLogger(this)
            logger = log4m.getLogger(this.LogPath);
            
            if ~strcmp(logger.fullpath, this.LogPath)
                logger = log4m.forceNewLogger(this.LogPath);
            end 
        end
        
        function log4Type = convertLogType2Log4m(~, logType)
            % clearly, a better, nicer, leaner and more elegant choice
            % would be to simple convert:
            % log4Type = double(logType)
            % this switch clause is safer though and shouldn't affect
            % performance significantly
            
            switch (logType)
                case (logs.LogType.ALL)
                    log4Type = log4m.ALL;
                case (logs.LogType.DEBUG)
                    log4Type = log4m.DEBUG;
                case (logs.LogType.ERROR)
                    log4Type = log4m.ERROR;
                case (logs.LogType.FATAL)
                    log4Type = log4m.FATAL;
                case (logs.LogType.INFO)
                    log4Type = log4m.INFO;
                case (logs.LogType.OFF)
                    log4Type = log4m.OFF;
                case (logs.LogType.TRACE)
                    log4Type = log4m.TRACE;
                case (logs.LogType.WARN)
                    log4Type = log4m.WARN;
            end
        end
        
        function logType = convertLog4mType2LogType(~, log4Type)
            % clearly, a better, nicer, leaner and more elegant choice
            % would be to simple convert:
            % logType = logs.LogType(logType)
            % this switch clause is safer though and shouldn't affect
            % performance significantly
            
            switch (log4Type)
                case (log4m.ALL)
                    logType = logs.LogType.ALL;
                case (log4m.DEBUG)
                    logType = logs.LogType.DEBUG;
                case (log4m.ERROR)
                    logType = logs.LogType.ERROR;
                case (log4m.FATAL)
                    logType = logs.LogType.FATAL;
                case (log4m.INFO)
                    logType = logs.LogType.INFO;
                case (log4m.OFF)
                    logType = logs.LogType.OFF;
                case (log4m.TRACE)
                    logType = logs.LogType.TRACE;
                case (log4m.WARN)
                    logType = logs.LogType.WARN;
            end
        end
    end
end

