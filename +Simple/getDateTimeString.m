function text = getDateTimeString(time, format, timezone)
if isnumeric(time)
    time = datetime(time, 'ConvertFrom', 'datenum');
elseif isa(time, 'duration')
    time = datetime(datestr(time));
end

if nargin >= 3
    time.TimeZone = timezone;
else
    time.TimeZone = 'UTC';
end

if nargin >= 2
    time.Format = strrep(format, 'full', 'eeee, dd MMM yyyy HH:mm:ss');
end

text = char(time);
end

