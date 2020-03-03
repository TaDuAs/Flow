function [ret, retErr] = roundError(val, err)
% Rounds the error to a single significant digit and then rounds
% the value's significant digits according to the rounded error
    import Simple.Math.*;
    % get error order of magnitude
    if (err == 0)
        ret = val;
        retErr = err;
        return;
    end

    % Find error value order of magnitude and round-to digit index
    errOOM = doom(err, true);

    % round the error
    retErr = arrayfun(@round, err, -errOOM);

    %round the value
    ret = arrayfun(@round, val, -errOOM);
end