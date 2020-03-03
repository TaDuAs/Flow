classdef Polynomial < Simple.Math.Ex.MathematicalExpression & mfc.IDescriptor
    %POLYNOMIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        coefficients = [];
        parameterName = 'x';
    end
    
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'coefficients', 'parameterName'};
            defaultValues = {};
        end
    end
    
    methods
        function this = Polynomial(p, parameterName)
            this.coefficients = p;
            
            if exist('parameterName', 'var') && ~isempty(parameterName)
                this.parameterName = parameterName;
            end
        end
        
        function value = invoke(this, args)
            value = polyval(this.coefficients, args);
        end
        
        function str = toString(this)
            import Simple.*;
            
            str = '(';
            order = length(this.coefficients);
            for i = 1:order - 1
                if this.coefficients(i) ~= 0
                    if length(str) > 1
                        str = strcat(str, '+');
                    end
                
                    str = strcat(str,...
                        [num2str(this.coefficients(i))...
                         cond(i < order, ['*' this.parameterName], '')...
                         cond(i < order - 1, ['^' num2str(order-i)], '')]);
                end
            end
            
            if length(str) > 1
                str = strcat(str, '+');
            end
            str = strcat(str, num2str(this.coefficients(order)));
            
            str = strcat(str, ')');
        end
    end
    
    methods (Access=protected)
        function func = getDerivative(this)
            func = Simple.Math.Ex.Polynomial(polyder(this.coefficients));
        end
    end
    
end

