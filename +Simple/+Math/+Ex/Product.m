classdef Product < Simple.Math.Ex.Series
    methods 
        function this = Product(elements)
            this@Simple.Math.Ex.Series(elements);
        end
    end
    
    methods (Access=protected)
        function func = getDerivative(this)
            import Simple.*;
            import Simple.Math.Ex.*;
            derivatives = List(length(this.elements), Zero);
            
            for i = 1:length(this.elements)
                currElement = this.elements.get(i);
                derivatives.add(...
                    Product(...
                        [...
                            currElement.derive()...
                            this.elements.minus(currElement, @(a,b) a.equals(b))...
                        ]));
            end
            
            func = Sum(derivatives);
        end
        
        function value = accumulateValue(this, accumulation, currValue)
            value = accumulation * currValue;
        end
        
        function str = getOperatorStringRepresentation(this)
            str = '*';
        end
    end
end

