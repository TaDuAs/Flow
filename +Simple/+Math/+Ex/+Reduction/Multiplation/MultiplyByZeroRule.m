classdef MultiplyByZeroRule < MultiplationReductionRule
% A*0 = 0
    methods
        function [func, didReduce] = reduceOperator(this, left, right)
            if left.equals(0) || right.equals(0)
                func = Zero();
                didReduce = true;
            end
        end
    end 
end