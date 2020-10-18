classdef RelayMessage < handle
    % RelayMessage is a simple input/output relay used to transfer data
    % between view and model (open/close views, interact with plots, etc.)
    
    properties
        Id;
        Data;
        Result struct;
    end
    
    methods
        function this = RelayMessage(id, data)
            this.Id = id;
            
            if nargin >= 2
                this.Data = data;
            else
                this.Data = struct();
            end
            
            this.Result = struct();
        end
    end
end

