function str = toString(value)
            Simple.obsoleteWarning();
    import Simple.*;

    if iscell(value)
        str = '{ ';
        for i = 1:length(value)
            if i > 1
                str = [str ', '];
            end
            str = [str toString(value{i})];
        end
        str = [str ' }'];
    elseif ischar(value)
        [n, m] = size(value);
        if n > 1
            str = '';
            for i = 1:n
                str = [str value(i, :) ';'];
            end
        else
            str = value;
        end
    elseif isnumeric(value)
        [n, m] = size(value);
        if n > 1
            str = '';
            for i = 1:n
                str = [str num2str(value(i, :)) cond(i<n, ';', '')];
            end
        else
            str = num2str(value);
        end
    elseif islogical(value)
        [n, m] = size(value);
        if n > 1
            str = '';
            for i = 1:n
                str = [str num2str(value(i, :)) ';'];
            end
        else
            str = num2str(value);
        end
    elseif isstruct(value)
        str = '{ ';
        fields = fieldnames(value);
        for i = 1:length(fields)
            if i > 1
                str = [str ', '];
            end
            fieldName = fields{i};
            fieldValue = value.(fieldName);
            str = [str fieldName ': ' toString(fieldValue)];
        end
        str = [str ' }'];
    end
end

