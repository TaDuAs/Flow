classdef ModelIndexer < mvvm.providers.IModelIndexer
    properties
        Index;
    end
    
    methods (Static)
        function isvalid = validateIndex(i)
            isvalid = iscell(i) && all(cellfun(@(c) islogical(c) || isnumeric(c) || ischar(c) || iscellstr(c) || isstring(c), i));
        end
    end
    
    methods
        function this = ModelIndexer(varargin)
            assert(mvvm.providers.ModelIndexer.validateIndex(varargin),...
                'Indices must be either numeric, logical, string, char-vector or character cellarrays');
            this.Index = varargin;
        end
        
        function value = getv(this, model)
            if istable(model)
                value = model{this.Index{:}};
            else
                value = model(this.Index{:});
            end
        end
        
        function model = setv(this, model, value)
            if istable(model) || (iscell(model) && ~iscell(value))
                model{this.Index{:}} = value;
            else    
                model(this.Index{:}) = value;
            end
        end
    end
end

