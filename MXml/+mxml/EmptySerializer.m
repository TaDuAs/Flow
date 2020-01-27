classdef EmptySerializer < mxml.ISerializer
    
    properties (Access=protected, Constant)
        DefaultMaintainedTypes string = "";
    end
    
    methods
        function save(this, obj, path)
        end
        function obj = load(this, path)
            obj = [];
        end
        function str = serialize(this, obj)
            str = '';
        end
        function obj = deserialize(this, str)
            obj = [];
        end
    end
end

