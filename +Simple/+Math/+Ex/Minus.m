classdef Minus < Simple.Math.Ex.Subtract
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {'rightExpression'};
            defaultValues = {};
        end
    end
    
    methods
        function this = Minus(expression)
            this@Simple.Math.Ex.Subtract(Simple.Math.Ex.Zero(), expression);
        end
        
        function str = toString(this)
            str = ['-' this.right().toString()];
        end
    end
    
end

