classdef Sum < Simple.Math.Ex.Series
    methods 
        function this = Sum(elements)
            this@Simple.Math.Ex.Series(elements);
        end
    end
    
    methods (Access=protected)
        function func = getDerivative(this)
            import Simple.Math.Ex.*;
            import Simple.*;
            derivatives = Simple.List(length(this.elements), Zero);
            
            for i = 1:length(this.elements)
                derivatives(i) = this.elements{i}.derive();
            end
            
            func = Sum(derivatives.vector);
        end
        
        function value = accumulateValue(this, accumulation, currValue)
            value = accumulation + currValue;
        end
        
        function str = getOperatorStringRepresentation(this)
            str = '+';
        end
    end
end

