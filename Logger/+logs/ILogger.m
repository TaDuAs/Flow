classdef (Abstract) ILogger < handle
    
    methods (Abstract) % log4m api
        
        setFilename(this, logPath);
        
        logPath = getFilename(this);
        
        setCommandWindowLevel(this, loggerIdentifier);
        
        setLogLevel(this, logLevel);
        
        % Log a message with specified level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        log(this, funcName, message, loglevel);
        
        % TRACE Log a message with the TRACE level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        trace(this, funcName, message);
        
        % TRACE Log a message with the DEBUG level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        debug(this, funcName, message);
 
        % TRACE Log a message with the INFO level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        info(this, funcName, message);
            
        % TRACE Log a message with the WARN level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        warn(this, funcName, message);
                
        % TRACE Log a message with the ERROR level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        error(this, funcName, message);
                
        % TRACE Log a message with the FATAL level
        %
        %   PARAMETERS:
        %       funcName - Name of the function or location from which
        %       message is coming.
        %       message - Text of message to log.
        % 
        fatal(this, funcName, message);
    end
end

