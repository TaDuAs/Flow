classdef Divide < Simple.Math.Ex.Operator
    methods
        function this = Divide(left, right)
            this@Simple.Math.Ex.Operator(left, right);
        end
    end
    
    methods (Access=protected)
        % value = f / g
        function value = operate(this, leftVal, rightVal)
            value = leftVal./rightVal;
        end
        
        % d(f/g)/dx = ((df/dx)*g - f*(dg/dx))/(g^2)
        function func = getOperatorDerivative(this, leftFunc, rightFunc)
            import Simple.Math.Ex.*;
            func = Divide(...
                Subtract(...
                    Multiply(leftFunc.derive(), rightFunc),...
                    Multiply(leftFunc, rightFunc.derive())),...
                Power(rightFunc, Scalar(2)));
        end
        
        function str = getOperatorStringRepresentation(this)
            str = '/';
        end
    end
    
    methods
        function func = evaluate(this)
        % Used for expression reduction.
        % for instance: X/1 = X; 0/X = 0;
            if this.left.equals(Simple.Math.Ex.Zero)
                func = Simple.Math.Ex.Zero;
            elseif this.right.equals(Simple.Math.Ex.One)
                func = this.left;
            else
                func = this.evaluate@Simple.Math.Ex.Operator();
            end
        end
    end
end