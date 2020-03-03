classdef EquationReductionManager < handle
    properties
        expressionReductionRules;
    end
    
    methods
        function init(this)
            rules = containers.Map();
            
            rules(class(Multiply())) = {AAMultiplationRule()};
            
            this.expressionReductionRules = rules;
        end
        
        function func = reduce(this, expression)
            
        end
    end
    
end

