classdef ApplicationStatus < double
    enumeration
        notAvailable (1),
        configuring (2),
        initializing (3),
        startup (4),
        loaded (5),
        terminated (6)
    end
end

