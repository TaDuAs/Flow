classdef X < Simple.Math.Ex.MathematicalExpression & mfc.IDescriptor
    properties
        parameterName = 'x'
    end
    
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'parameterName'};
            defaultValues = {};
        end
    end
    
    methods
        function this = X(parameterName)
            if exist('parameterName', 'var') && ~isempty(parameterName)
                this.parameterName = parameterName;
            end
        end
        
        function value = invoke(this, args)
            value = args;
        end
        
        function str = toString(this)
            str = this.parameterName;
        end
    end
    
    methods (Access=protected)
        function func = getDerivative(this)
            func = Simple.Math.Ex.One;
        end
        
        function b = determineEquality(this, expression)
            b = isa(expression, 'Simple.Math.Ex.X');
        end
    end
end

