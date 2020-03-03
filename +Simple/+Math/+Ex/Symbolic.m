classdef Symbolic < Simple.Math.Ex.MathematicalExpression & mfc.IDescriptor
    %SYMBOLIC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        expression sym;
    end
    
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'expression'};
            defaultValues = {};
        end
    end
    
    methods
        function this = Symbolic(ex)
            this.expression = ex;
        end
        
        % Invokes the function to get the value in the specified arguments
        % array
        function value = invoke(this, args)
            value = double(subs(this.expression, args));
        end
        
        % Gets the string representation of the expression
        function str = toString(this)
            str = char(this.expression);
        end
    end
    
    methods (Access=protected)
        % Gets the derivative of the function
        function func = getDerivative(this)
            func = Simple.Math.Ex.Symbolic(diff(this.expression));
        end
    
    end
end

