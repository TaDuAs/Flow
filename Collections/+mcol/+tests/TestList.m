classdef TestList < mcol.ICollection & mcol.SelfExtendingRow
    %TESTLIST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        List = nan(2,10);
    end
    
    methods
        function this = TestList()
            this@mcol.SelfExtendingRow('List', nan(2,1), 10);
        end
        
        function setVector(this, arr)
            this.List = arr;
        end
        
        function items = getv(this, i)
            items = this.List(:,i);
        end
    end
end

