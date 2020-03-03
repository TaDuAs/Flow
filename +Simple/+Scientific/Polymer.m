classdef (Abstract) Polymer < handle
    %POLYMER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        
        function n = repeatingUnits(this, mw)
            if numel(this) > 1 && numel(mw) == 1
                mw = repmat(mw, size(this));
            end
                
            n = zeros(size(this));
            for i = 1:numel(this)
                pol = this(i);
                n(i) = round(mw(i) / pol.getRepeatingUnitMw());
            end
        end
        
        function l = backboneLength(this, mw)
            % length of chain
            l = this.repeatingUnits(mw) .* this.persistenceLength();
        end
        
    end
    
    methods (Abstract)
        mw = getRepeatingUnitMw(this)
        l = getRepeatingUnitStretchedBackboneLength(this)
        pl = persistenceLength(this)
    end
end

