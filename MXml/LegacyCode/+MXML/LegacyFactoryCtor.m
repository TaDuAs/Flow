classdef LegacyFactoryCtor < mfc.FunctionHandleCtor
    methods
        function this = LegacyFactoryCtor(type, ctor)
            this@mfc.FunctionHandleCtor(type, ctor);
        end
    end
end

