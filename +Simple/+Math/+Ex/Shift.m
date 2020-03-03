classdef Shift < Simple.Math.Ex.MathematicalExpression & mfc.IDescriptor
    properties
        expression;
        shift;
    end
    
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'expression', 'shift'};
            defaultValues = {};
        end
    end
    
    methods
        function this = Shift(expression, shift)
            this.expression = expression;
            this.shift = shift;
        end
        
        function value = invoke(this, args)
            value = this.expression.invoke(args + this.shift);
        end
        
        function str = toString(this)
            str = this.expression.toString();
        end
        
        function func = evaluate(this)
            func = Simple.Math.Ex.Shift(this.expression.evaluate(), this.shift);
        end
    end
    
    methods (Access=protected)
        function func = getDerivative(this)
            func = Simple.Math.Ex.Shift(this.expression.getDerivative(), this.shift);
        end
        
        function b = determineEquality(this, expression)
            b = isa(expression, 'Simple.Math.Ex.Shift') &&...
                this.shift == expression.shift &&...
                expression.expression.determineEquality(this.expression);
        end
    end
end

