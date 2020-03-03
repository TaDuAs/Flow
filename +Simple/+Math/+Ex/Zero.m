classdef Zero < Simple.Math.Ex.Scalar
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {};
            defaultValues = {};
        end
    end
    
    methods
        function this = Zero()
            this@Simple.Math.Ex.Scalar(0);
        end
    end
end