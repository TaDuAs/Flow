classdef LineBreak < flow.ComponentBase
    methods
        function this = LineBreak(varargin)
            this@flow.ComponentBase();
            
            this.parsePVPairs(varargin{:});
        end
    end
end

