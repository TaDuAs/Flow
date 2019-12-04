classdef (Abstract) IXmlInterpreter < handle
% This interface implements the methods required for property extraction
% from xml elements
    methods (Abstract)
        value = interpretElement(this, node, version);
        value = interpretAttribute(this, attr, version);
    end
end

