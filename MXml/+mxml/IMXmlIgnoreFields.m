classdef IMXmlIgnoreFields < handle
    methods (Abstract, Hidden)
        ignoreList = getMXmlIgnoreFieldsList(this);
    end
end

