function [datatype, isList] = checkAttributes(element)
    datatype = [];
    isList = false;
    for j = 1:length(element.Attributes)
        attr = element.Attributes(j);
        if strcmp('type', attr.Name)
            datatype = attr.Value;
        elseif strcmp('isList', attr.Name)
            isList = gen.str2boolean(attr.Value);
        end
    end
end