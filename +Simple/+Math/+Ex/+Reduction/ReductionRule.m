classdef (Abstract) ReductionRule < handle & matlab.mixin.Heterogeneous
    methods
        function validateInput(this, expression)
            if ~isa(expression, this.typeName)
                error([class(this) ' only handles expressions of type ' this.typeName]);
            end
        end
    end
    
    methods (Abstract)
        [func, didReduce] = reduce(this, expression);
        
        name = typeName(this);
    end
end

