classdef ResourceManager < sui.IResourceManager
    %RESOURCEMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cache;
    end
    
    methods (Access=private)
        function this = ResourceManager()
            this.cache = containers.Map();
        end
    end
    
    methods (Static)
        function rm = instance()
            persistent mgr;
            if isempty(mgr)
                mgr = ResourceManager();
            end
            rm = mgr;
        end
    end
    
    methods
        
        
        function img = getImage(this, path)
            if this.cache.isKey(path)
                img = this.cache(path);
            else
                img = imread(path);
                this.cache(path) = img;
            end
        end
    end
end

