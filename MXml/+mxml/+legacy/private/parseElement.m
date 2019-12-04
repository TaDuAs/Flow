% Parses an element by generating the appropriate type
function [value, empty] = parseElement(element)
    value = [];
    empty = false;

    % ignore empty text nodes, remarks, etc.
    if isVirtualXMLNode(element)
        empty = true;
        return;
    % don't ignore empty elements, return null instead
    elseif isempty(element.Children)
        return;
    end

    [datatype, isList] = checkAttributes(element);
    if isempty(datatype)
        ex = MException('MXML:load:missingDataType', 'Cannot parse xml file. Missing element data type.');
        throw(ex);
    end

    switch datatype
        case 'char'
            value = element.Children(1).Data;
        case 'double'
            strVal = strsplit(element.Children(1).Data, ';');
            n = length(strVal);
            for vi = 1:length(strVal)
                strValCurrRow = strsplit(strVal{vi}, ' ');
                temp = str2double(strValCurrRow);
                if isempty(value)
                    value = zeros(n, length(temp));
                end
                value(vi,:) = temp;
            end
        case 'logical'
            value = gen.str2boolean(element.Children(1).Data);
        case 'cell'
            value = parseCellArray(element);
        otherwise
            superClassList = superclasses(datatype);
            if any(strcmp(superClassList, 'mxml.legacy.IIterable')) % implements MXML.IIterable
                valueArr = parseVector(element);
%                 if ~isempty(valueArr)
%                     emptyValue = mxml.legacy.newempty(valueArr(1));
%                     iterableLength = length(valueArr);
%                 else
%                     emptyValue = [];
%                     iterableLength = [];
%                 end
                factory = mxml.legacy.Factory.instance;
                value = factory.construct(datatype);
%                 struct('vector', valueArr, 'emptyValue', emptyValue, 'iterableLength', iterableLength));
                value.setVector(valueArr);
            elseif isList
                value = parseVector(element);
            else
                % Generate dynamic struct
                value = parseGenericElement(element, datatype);

                if ~strcmp(datatype, 'struct')
                    factory = mxml.legacy.Factory.instance;
                    value = factory.construct(datatype, value);
                end
            end
    end
end