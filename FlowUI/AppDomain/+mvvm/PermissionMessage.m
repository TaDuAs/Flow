classdef PermissionMessage < handle
    %PERMISSIONMESSAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Id;
        Data;
        PermissionGranted (1,1) logical;
    end
    
    properties (Access=private)
        Forbidden (1,1) logical;
    end
    
    methods
        function this = PermissionMessage(id, data)
            this.Id = id;
            
            if nargin >= 2
                this.Data = data;
            else
                this.Data = [];
            end
            
            this.PermissionGranted = true;
            this.Forbidden = false;
        end
        
        function forbid(this)
            this.Forbidden = true;
            this.PermissionGranted = false;
        end
        
        function allow(this)
            this.PermissionGranted = ~this.Forbidden;
        end
    end
end

