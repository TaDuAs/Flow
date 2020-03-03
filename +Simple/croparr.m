function [x, ind] = croparr(x, a, b)
% crops vector x to specified range
% croparr(x, range)
%   range: [start end]
% croparr(x, fragment, startAt)
%   startAt: 'start'|'end'|specified numeric index
%   fragment: between 0 and 1
    import Simple.*;
    range = [];
    if (nargin == 2)
        if length(a) ~= 2
            error('specified array fragment must be a two value vector specifying the start and end positions to crop');
        end
        if sum(a>=1) == 2
            range = a;
        elseif sum(a>=0 & a<=1) == 2
            n = length(x);
            fragment = a;
            range = ceil(fragment * n);
            range(range == 0) = 1;
        else
            error('specified fragment must be either two integers specifying the two indices to crop between or two values between 0 and 1 indicating the start and end positions of the wanted fragment');
        end
    elseif (nargin == 3)
        % Generate range from fragment and start position
        fragment = a;
        startAt = b;
        if fragment == 0
            x = [];
            return;
        elseif ~isempty(fragment) && ~isempty(startAt) && fragment ~= 1
            % validate fragment
            if fragment > 1 || fragment < 0
                error('specified array fragment must be a numeric value between 0 and 1.');
            end
            
            % if start position is 'start' or 'end'
            if ischar(startAt)
                if strcmp(startAt, 'start')
                    startAt = 1;
                    endAt = startAt + ceil(fragment * length(x));
                elseif strcmp(startAt, 'end')
                    startAt = floor((1 - fragment) * length(x)) + 1;
                    endAt = length(x);
                else
                    error(['start position ' startAt ' is not a valid value. use either ''start'', ''end'' or numeric index']);
                end
            elseif mod(startAt, 1) ~= 0
                error('specified numeric index start position must be a whole number');
            else
                endAt = startAt + ceil(fragment * length(x));
            end
            range = [startAt endAt];
        end
    end
    
    % if range was generated or specified, crop arrays
    if ~isempty(range)
        ind = range(1):range(2);
        x = x(ind);
    end
end

