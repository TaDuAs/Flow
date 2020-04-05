classdef AppStatus < double
    enumeration
        NotAvailable (1),
        Configuring (2),
        Initializing (3),
        Startup (4),
        Loaded (5),
        Terminated (6),
        SessionLoaded (7)
    end
end

