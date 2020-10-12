classdef LogType < uint8
    %LOGTYPE Summary of this class goes here
    %   Detailed explanation goes here
    enumeration
        ALL (0);
        TRACE (1);
        DEBUG (2);
        INFO (3);
        WARN (4);
        ERROR (5);
        FATAL (6);
        OFF (7);
    end
end

