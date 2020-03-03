classdef Exponent < Simple.Math.Ex.Power
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'expression'};
            defaultValues = {};
        end
    end
    
    methods
        function this = Exponent(expression)
            this@Simple.Math.Ex.Power(Scalar(exp(1)), expression);
        end
        
        function str = toString(this)
            str = ['e^' this.right().toString()];
        end
    end
    
    methods (Access=protected)
        % d(e^f)/dx = f'*e^f
        function func = getOperatorDerivative(this, leftFunc, rightFunc)
            func = Simple.Math.Ex.Multiply(this, rightFunc.derive());
        end
    end
end

