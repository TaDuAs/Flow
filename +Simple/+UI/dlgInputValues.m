function [ values ] = dlgInputValues(fields, defaults, datatypes, title, lines, ids)
            Simple.obsoleteWarning('Simple.UI');
    import Simple.*;
    defaultAnswersStrings = cell(1,length(defaults));
    if isstruct(defaults)
        numFields = length(fields);
        defValues = cell(1, numFields);
        for i = 1:numFields
            defValues{i} = defaults.(ids{i});
        end
        defaults = defValues;
    end
    for i = 1:length(defaults)
        if strcmp(datatypes{i}, 'bool')
            defaultAnswersStrings{i} = cond(defaults{i}, 'true', 'false');
        elseif strcmp(datatypes{i}, '{string}')
            defaultAnswersStrings{i} = cond(isempty(defaults{i}), '', @() strjoin(defaults{i}));
        elseif isnumeric(defaults{i})
            defaultAnswersStrings{i} = num2str(defaults{i});
        elseif ischar(defaults{i})
            defaultAnswersStrings{i} = defaults{i};
        end
    end

    answer = inputdlg(...
        fields,... % Input textboxes titles
        title,... % Dialogue title
        lines,... % number of lines per input
        defaultAnswersStrings); % Default values
    
    values = cell(1,length(fields));
    for i = 1:length(answer)
        if isempty(answer{i})
            values{i} = defaults{i};
        elseif strcmp(datatypes{i}, 'string')
            values{i} = answer{i};
        elseif strcmp(datatypes{i}, '{string}')
            values{i} = strsplit(answer{i});
        elseif strcmp(datatypes{i}, 'double')
            charNumbers = strsplit(answer{i});
            number = str2double(charNumbers);
            if any(isnan(number)) || any(isinf(number)) || isempty(number)
                number = defaults{i};
            end
            values{i} = number;
        elseif strcmp(datatypes{i}, 'double|string')
            val = str2double(answer{i});
            if isnan(val)
                val = answer{i};
            end
            values{i} = val;
        elseif strcmp(datatypes{i}, 'bool')
            val = lower(answer{i});
            if strcmp(val, 'true')
                val = true;
            elseif strcmp(val, 'false')
                val = false;
            else
                val = defaults{i};
            end
            values{i} = val;
        end
    end
    
    if exist('ids', 'var')
        retVal = struct();
        for i = 1:length(ids)
            retVal.(ids{i}) = values{i};
        end
        values = retVal;
    end
end

