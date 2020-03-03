classdef (Abstract) MathematicalExpression < handle & matlab.mixin.Heterogeneous
    methods
        function func = derive(this, n)
            if ~exist('n', 'var')
                n = 1;
            elseif n < 0
                error('derivative order ''n'' must be a positive whole numer');
            end
            
            func = this;
            for i = 1:n
                func = func.evaluate().getDerivative().evaluate();
            end
        end
    end
    
    methods (Static, Sealed, Access = protected)
        function default_object = getDefaultScalarElement()
            default_object = Simple.Math.Ex.Zero();
        end
    end
    
    methods (Abstract)
        % Invokes the function to get the value in the specified arguments
        % array
        value = invoke(this, args);
        
        % Gets the string representation of the expression
        str = toString(this);
    end
    
    methods (Abstract, Access=protected)
        % Gets the derivative of the function
        func = getDerivative(this);
    end
    
    methods
        function func = evaluate(this)
            func = this;
        end
        
        function isValid = validateExpression(this, func)
            isValid = isa(func, 'Simple.Math.Ex.MathematicalExpression');
        end
        
        % Mostly for evaluating 0 and 1
        function b = equals(this, expression)
            b = this.evaluate().determineEquality(expression.evaluate());
        end
    end
    
    methods (Access=protected)
        function b = determineEquality(this, expression)
            b = this == expression;
        end
    end
end

