classdef PEG < Simple.Scientific.Polymer
    % PEG: H-(O-CH2-CH2)-OH 
    
    properties (Constant)
        repeatingUnitMw = 12 * 2 + 1 * 4 + 16; % 4H+2C+O
        repeatingUnitStretchedLength = Simple.Scientific.sp3ChainLength(...
            [Simple.Scientific.Chemistry.BondLengths.CC_sp3 2*Simple.Scientific.Chemistry.BondLengths.CO_sp3]); % nm %%% could be 0.28 nm per monomer unit?
        experimentalPersistenceLength = 0.38; % nm, reported in literature
    end
    
    properties
        Mw;
    end
    
    methods
        function this = PEG(mw)
            if nargin >= 1
                if numel(mw) > 1
                    this = arrayfun(@Simple.Scientific.PEG, mw);
                else
                    this.Mw = mw;
                end
            end
        end
        
        function l = backboneLength(this)
            l = backboneLength@Simple.Scientific.Polymer(this, [this.Mw]);
        end
        
        function pl = persistenceLength(this)
            pl = [this.experimentalPersistenceLength];
        end
        
        function mw = getRepeatingUnitMw(this)
            mw = [this.repeatingUnitMw];
        end
    end
    
    methods (Hidden)
        function l = getRepeatingUnitStretchedBackboneLength(this)
            l = [this.repeatingUnitStretchedLength];
        end
    end
end