function bool = isdebug()
% Determine whether running in debug mode to allow for better debug prints
    bool = feature('IsDebugMode');
end

