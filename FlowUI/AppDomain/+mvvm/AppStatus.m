classdef AppStatus < double
    enumeration
        NotAvailable (1),
        Configuring (2),
        SettingUp (3),
        Initializing (4),
        Startup (5),
        Loaded (6),
        Terminated (7),
        SessionLoaded (8)
    end
end

