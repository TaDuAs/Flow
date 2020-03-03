classdef Multiply < Simple.Math.Ex.Operator
    methods
        function this = Multiply(left, right)
            this@Simple.Math.Ex.Operator(left, right);
        end
    end
    
    methods (Access=protected)
        % value = f * g
        function value = operate(this, leftVal, rightVal)
            value = leftVal.*rightVal;
        end
        
        % d(f*g)/dx = (df/dx)*g + f*(dg/dx)
        function func = getOperatorDerivative(this, leftFunc, rightFunc)
            import Simple.Math.Ex.*;
            func = Add(...
                Multiply(leftFunc.derive(), rightFunc),...
                Multiply(leftFunc, rightFunc.derive()));
        end
        
        function b = isCommutative(this)
        % Multiplication is commutative
            b = true;
        end
        
        function str = getOperatorStringRepresentation(this)
            str = '*';
        end
    end
    
    methods
        function func = evaluate(this)
        % Used for expression reduction.
        % for instance: 1*X = X; 0*X = 0; you get the idea
            lex = this.left;
            rex = this.right;
        
            if lex.equals(Simple.Math.Ex.Zero) || rex.equals(Simple.Math.Ex.Zero)
                func = Simple.Math.Ex.Zero;
            elseif lex.equals(Simple.Math.Ex.One)
                func = rex;
            elseif rex.equals(Simple.Math.Ex.One)
                func = lex;
            else
                func = this.evaluate@Simple.Math.Ex.Operator();
            end
        end
    end
end