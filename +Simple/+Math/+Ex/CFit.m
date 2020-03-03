classdef CFit < Simple.Math.Ex.MathematicalExpression & mfc.IDescriptor
    %CFIT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fitobj;
    end
    
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'fitobj'};
            defaultValues = {};
        end
    end
    
    methods
        function this = CFit(fitobj)
            this.fitobj = fitobj;
        end
        
        % Invokes the fit object function
        function value = invoke(this, args)
            value = feval(this.fitobj, args);
        end
        
        % Gets the string representation of the expression
        function str = toString(this)
            cf = this.fitobj;
            str = char(cf);
            args = fieldnames(cf);
            
            for i = 1:numel(args)
                param = args{i};
                str = strrep(str, param, num2str(cf.(param)));
            end
        end
    end
    
    methods (Access=protected)
        % Gets the derivative of the function
        function func = getDerivative(this)
            % differentiate only returns the values
            symExpression = str2sym(this.toString());
            func = Simple.Math.Ex.Symbolic(diff(symExpression));
        end
    
    end
end

