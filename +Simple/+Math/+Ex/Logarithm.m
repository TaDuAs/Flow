classdef Logarithm < Simple.Math.Ex.MathematicalExpression & mfc.IDescriptor
    %LAN Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        base = [];
        expression = [];
    end
    
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'base', 'expression'};
            defaultValues = {};
        end
    end
    
    methods
        function this = Logarithm(base, expression)
            this.base = base;
            this.expression = expression.evaluate();
        end
        
        function value = invoke(this, args)
            value = logb(this.expression.invoke(args), this.base);
        end
        
        function func = evaluate(this)
        % Used for expression reduction.
        % for instance: Log(1) = 0; Log_a(a^X) = X;
            import Simple.Math.Ex.*;
            if this.expression.equals(One)
                func = Zero;
            elseif isa(this.expression, 'Simple.Math.Ex.Power') && this.expression.left.equals(this.base)
                func = this.expression.right;
            else
                func = this.evaluate@Simple.Math.Ex.MathematicalExpression();
            end
        end
        
        function str = toString(this)
            switch this.base
                case exp(1)
                    logStr = 'Ln';
                case 10
                    logStr = 'Log';
                otherwise
                    logStr = ['Log_' num2str(this.base)];
            end
            
            str = this.expression.toString();
            
            if ~isempty(str) && ~strcmp(str(1), '(')
                str = ['(' str ')'];
            end
            
            str = [logStr str];
        end
    end
    
    methods (Access=protected)
        % log_b(f) = ln(f)/ln(b) = const*ln(f)
        % d(log_b(f))/dx = d(const*ln(f))/dx = const * f'/f
        function func = getDerivative(this)
            const = logb(this.base);
            f = this.expression;
            func = Simple.Math.Ex.Multiply(Simple.Math.Ex.Scalar(const), Simple.Math.Ex.Divide(f.derive(), f));
        end
    end
    
end

