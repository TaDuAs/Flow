classdef AAMultiplationRule < MultiplationReductionRule
% Reduces multiplations of the same expression to power expressions
% A*A = A^2
% A^b*A^c = A^(b+c)
% A*(6*(A*(A+1))) = 6(A+1)*A^2
    methods
        function [func, didReduce] = reduce(this, expression)
            list = this.digDown(expression);
            scalars = Simple.List(length(list));
            nonScalars = Simple.List(length(list), Zero());
            
            for i = 1:length(list)
                exp = list(i);
                
                if isa(exp, 'Scalar')
                    scalars.add(exp.scalar);
                elseif isa(list(i), 'Power')
                    nonScalars.add(exp);
                else
                    nonScalars.add(Power(exp, One));
                end
            end
            
            % Group by power bases, use equals method for comparison
            multipliers = nonScalars.groupBy(@(powerExp) powerExp.left, @(a, b) a.equals(b));
            
            for i = 1:length(multiplationBases)
                currMultiplier = multipliers(i);
                currMultiplierElements = currMultiplier.elements;
                summedScalarPowers = 0;
                for j = 1:length(currMultiplierElements)
                    if isa(currMultiplierElements{j}, 'Scalar');
                        summedScalarPowers = summedScalarPowers + currMultiplierElements{j}.scalar;
                    else
                        
                    end
                end
            end
            
            if scalars.any()
                scalarValue = prod(scalars.vector);
                func = Multiply(Scalar(scalarValue), func);
            end
        end
        
        function [func, didReduce] = reduceOperator(this, left, right)
            % Treat everything as Power expressions
            if ~isa(left, 'Power')
                left = Power(left, 1);
            end
            if ~isa(right, 'Power')
                right = Power(right, 1);
            end
            
            % If the two power expressions have similar bases, merge them
            if left.left.equals(right.left)
                func = Power(left, left.right + right.right);
                didReduce = true;
            end
        end
    end 
end