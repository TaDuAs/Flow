classdef (Abstract) OperatorReductionRule < ReductionRule
    methods
        function [func, didReduce] = reduce(this, expression)
            % Ensure the expression is valid
            this.validateInput(expression);
            
            left = expression.left();
            right = expression.right();
            
            [func, didReduce] = this.reduceOperator(left, right);
        end
        
        function expressionList = digDown(this, expression)
        % Digs down the tree to find all concatenable expressions
        
            list = Simple.List(20, Zero());
            
            % Dig down the tree to find all concatenable expressions
            this.doDigDown(expression, list);
            
            expressionList = list.vector;
        end
    end
    
    methods (Abstract)
        [func, didReduce] = reduceOperator(this, left, right);
    end
    
    methods (Access = Private)
        
        function doDigDown(this, expression, list)
            if isa(expression, this.typeName)
                this.digDown(expression.left, list);
                this.digDown(expression.right, list);
            else
                list.add(expression);
            end
        end
    end
end