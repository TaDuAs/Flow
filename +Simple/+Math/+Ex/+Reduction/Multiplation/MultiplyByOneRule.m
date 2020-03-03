classdef MultiplyByOneRule < MultiplationReductionRule
% A*1 = A
    methods
        function [func, didReduce] = reduceOperator(this, left, right)
            if left.equals(1)
                func = left;
                didReduce = true;
            elseif right.equals(1)
                func = right;
                didReduce = true;
            end
        end
    end 
end