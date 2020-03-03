classdef One < Simple.Math.Ex.Scalar
    methods % meta data
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            ctorParams = {};
            defaultValues = {};
        end
    end
    
    methods
        function this = One()
            this@Simple.Math.Ex.Scalar(1);
        end
    end
end