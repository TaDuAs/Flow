classdef PermissionMessage < handle
    %PERMISSIONMESSAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Id;
        Data;
        PermissionGranted (1,1) logical;
    end
    
    methods
        function this = RelayMessage(id, data)
            this.Id = id;
            
            if nargin >= 2
                this.Data = data;
            else
                this.Data = [];
            end
            
            this.PermissionGranted = true;
        end
        
        function forbid(this)
            this.PermissionGranted = false;
        end
    end
end

