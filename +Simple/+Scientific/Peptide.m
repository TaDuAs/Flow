classdef Peptide < Simple.Scientific.Polymer
    %PEPTIDE Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant)
        repeatingUnitStretchedLength = Simple.Scientific.sp3ChainLength(...
            [Simple.Scientific.Chemistry.BondLengths.CC_sp3 Simple.Scientific.Chemistry.BondLengths.CN_amine Simple.Scientific.Chemistry.BondLengths.CN_amide]);
    end
    
    properties
        sequence;
        experimentalPersistenceLength = 0.4; % nm, reported in literature
    end
    
    methods
        function this = Peptide(sequence)
            if nargin < 1; sequence = ''; end
                
            if iscellstr(sequence) || (isstring(sequence) && ~isscalar(sequence))
                sequenceList = string(sequence);
                this = arrayfun(@Simple.Scientific.Peptide, sequenceList);
            else
                this.sequence = sequence;
            end
        end
        
        function mw = molarWeight(this)
            mw = reshape(cellfun(@molweight, {this.sequence}), size(this));
        end
        
        function n = repeatingUnits(this, ~)
            n = reshape(cellfun(@strlength, {this.sequence}), size(this));
        end
         
        function l = backboneLength(this)
            if numel(this) == 1
                l = backboneLength@Simple.Scientific.Polymer(this, []);
            else
                l = arrayfun(@backboneLength, this);
            end
        end
        
        function mw = getRepeatingUnitMw(this)
            mw = [];
        end
        
        function pl = persistenceLength(this)
            pl = [this.experimentalPersistenceLength];
        end
    end
    
    methods (Hidden)
        function l = getRepeatingUnitStretchedBackboneLength(this)
            l = this.repeatingUnitStretchedLength;
        end
    end
    
end

