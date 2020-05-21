function bool = isdebug()
% Determine whether running in debug mode to allow for better debug prints
            Simple.obsoleteWarning();
    bool = feature('IsDebugMode');
end

