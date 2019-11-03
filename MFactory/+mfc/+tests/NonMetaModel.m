classdef NonMetaModel < handle
    %NONMETAMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id;
        x;
        y;
    end
    
    methods
        function this = NonMetaModel(id, x, y)
            if nargin >= 1 && ~isempty(id)
                this.id = id;
            end
            if nargin >= 2 && ~isempty(x)
                this.x = x;
            end
            if nargin >= 3 && ~isempty(y)
                this.y = y;
            end
        end
    end
end

