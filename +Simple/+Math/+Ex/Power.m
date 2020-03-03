classdef Power < Simple.Math.Ex.Operator
    methods
        function this = Power(left, right)
            this@Simple.Math.Ex.Operator(left, right);
        end
    end
    
    methods (Access=protected)
        % value = f^g
        function value = operate(this, leftVal, rightVal)
            value = leftVal.^rightVal;
        end
        
        % d(f^g)/dx = f^g*(f'*g/f + g'ln(f))
        function func = getOperatorDerivative(this, leftFunc, rightFunc)
            import Simple.Math.Ex.*;
            func = Multiply(...
                this,...
                Add(...
                    Multiply(leftFunc.derive(), Divide(rightFunc, leftFunc)),...
                    Multiply(rightFunc.derive(), Logarithm(exp(1), leftFunc))));
        end
        
        function str = getOperatorStringRepresentation(this)
            str = '^';
        end
    end
    
    methods
        function func = evaluate(this)
        % Used for expression reduction.
        % for instance: 1^X = 1; X^0 = 1; a^log_a(X) = X;
            import Simple.Math.Ex.*;
            if this.left.equals(Zero)
                func = Zero;
            elseif this.right.equals(Zero)
                func = One;
            elseif this.left.equals(One)
                func = One;
            elseif this.right.equals(One)
                func = this.left;
            elseif isa(this.right, 'Simple.Math.Ex.Logarithm') && this.left.equals(this.right.base)
                func = this.right.expression;
            else
                func = this.evaluate@Simple.Math.Ex.Operator();
            end
        end
    end
end