function loglevel = validateLogType(loglevel)
    if isnumeric(loglevel) || gen.isSingleString(loglevel)
        loglevel = logs.LogType(loglevel);
    elseif ~isa(loglevel, 'logs.LogType')
        throw(MException('logs:InvalidLogLevel', 'loglevel must be of convertible to logs.LogType type'));
    end
end

