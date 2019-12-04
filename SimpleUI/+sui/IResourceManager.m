classdef (Abstract) IResourceManager < handle
    methods (Abstract)
        img = getImage(this, path);
    end
end

