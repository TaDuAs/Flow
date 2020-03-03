classdef Add < Simple.Math.Ex.Operator
    methods
        function this = Add(left, right)
            this@Simple.Math.Ex.Operator(left, right);
        end
    end
    
    methods (Access=protected)
        function value = operate(this, leftVal, rightVal)
        % value = f + g
            value = leftVal + rightVal;
        end
        
        function func = getOperatorDerivative(this, leftFunc, rightFunc)
        % d(f+g)/dx = df/dx + dg/dx
            func = Simple.Math.Ex.Add(leftFunc.derive(), rightFunc.derive());
        end
        
        function b = isCommutative(this)
        % Addition is commutative
            b = true;
        end
        
        function str = getOperatorStringRepresentation(this)
            str = '+';
        end
    end
    
    methods
        function func = evaluate(this)
        % Used for expression reduction.
        % for instance: 0+X = X
            import Simple.Math.Ex.*;
            if this.left.equals(Simple.Math.Ex.Zero)
                func = this.right;
            elseif this.right.equals(Simple.Math.Ex.Zero)
                func = this.left;
            else
                func = this.evaluate@Simple.Math.Ex.Operator();
            end
        end
    end
end

