classdef ViewID
    %VIEWID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Type string;
        ID {gen.valid.mustBeNumericOrTextualScalar};
    end
    
    methods
        function this = ViewID(type, vid)
            this.Type = type;
            
            if nargin >= 2
                this.ID = vid;
            else
                this.ID = '';
            end
        end
        
        function tf = eq(a, b)
            if ischar(b) || iscellstr(b) || isstring(b)
                b = string(b);
                b = arrayfun(@mvvm.view.ViewID, b);
            elseif ~isa(b, 'mvvm.view.ViewID')
                throw(MException('mvvm:view:ViewID:eq', 'compared object must be a mvvm.view.ViewID or a textual ID of a view'));
            end
            
            if numel(a) > 1
                multiVal = a;
                singleVal = b;
                if numel(b) > 1
                    throw(MException('mvvm:view:ViewID:eq:TooManyToCompare', 'can''t compare two vectors of mvvm.view.ViewID. Can only compare scalars or vector to scalar'));
                end
            else
                multiVal = b;
                singleVal = a;
            end 
            
            tf = ismember(singleVal.Type, [multiVal.Type]) & arrayfun(@(vid) isequal(vid.ID, singleVal.ID), multiVal);
        end
        
        function tf = ne(a, b)
            tf = ~eq(a, b);
        end
        
        function str = toString(this)
            if isempty(this.ID) || (isstring(this.ID) && this.ID == "")
                str = this.Type;
            elseif isnumeric(this.ID)
                str = strcat(this.Type, "_", num2str(this.ID));
            else
                str = strcat(this.Type, "_", this.ID);
            end
        end
    end
end

