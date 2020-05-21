classdef ClassFactoryBuilder < handle
    %classFactoryINSTANTIATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function initFactory(this, classFactory)
            Simple.obsoleteWarning('Simple.App');
            import Simple.*;
            import Simple.Math.Ex.*;
               
            classFactory.addConstructor('Simple.List', @(data) Simple.List());

            function oom = oomConverter(value)
                if ischar(value) || isStringScalar(value)
                    value = regexprep(value, '.*\.', '');
                    oom = Simple.Math.OOM(value);
                else
                    oom = Simple.Math.OOM(value);
                end
            end
            
            classFactory.addConstructor('Simple.Math.OOM', @(data) oomConverter(data));
            
            % Mathematical Expressions
            classFactory.addConstructor('Simple.Math.Ex.Scalar', @(data) Scalar(data.scalar));
            classFactory.addConstructor('Simple.Math.Ex.One', @(data) One);
            classFactory.addConstructor('Simple.Math.Ex.Zero', @(data) Zero);
            classFactory.addConstructor('Simple.Math.Ex.Add', @(data) Add(data.leftExpression, data.rightExpression));
            classFactory.addConstructor('Simple.Math.Ex.Subtract', @(data) Subtract(data.leftExpression, data.rightExpression));
            classFactory.addConstructor('Simple.Math.Ex.Multiply', @(data) Multiply(data.leftExpression, data.rightExpression));
            classFactory.addConstructor('Simple.Math.Ex.Divide', @(data) Divide(data.leftExpression, data.rightExpression));
            classFactory.addConstructor('Simple.Math.Ex.Power', @(data) Power(data.leftExpression, data.rightExpression));
            classFactory.addConstructor('Simple.Math.Ex.Minus', @(data) Minus(data.rightExpression));
            classFactory.addConstructor('Simple.Math.Ex.Exponent', @(data) Exponent(data.rightExpression));
            classFactory.addConstructor('Simple.Math.Ex.Logarithm', @(data) Logarithm(data.base, data.expression));
            classFactory.addConstructor('Simple.Math.Ex.Polynomial', @(data) Polynomial(data.coefficients, data.parameterName));
            classFactory.addConstructor('Simple.Math.Ex.Product', @(data) Product(data.elements));
            classFactory.addConstructor('Simple.Math.Ex.Shift', @(data) Shift(data.expression, data.shift));
            classFactory.addConstructor('Simple.Math.Ex.Sum', @(data) Sum(data.elements));
            classFactory.addConstructor('Simple.Math.Ex.X', @(data) X(data.parameterName));
            
            classFactory.addConstructor('Simple.App.MXmlDataAccessor', @(data) MXmlDataAccessor(data.exporter, data.batchPath, data.processedResultsPath, data.errorLogPath));
            
            classFactory.addConstructor('Simple.Pipeline',@(data) Simple.Pipeline(Simple.getobj(data, 'shouldPrintTaskTimespan')).addTask(data.list.vector()));
        end
         
    end
    
end

